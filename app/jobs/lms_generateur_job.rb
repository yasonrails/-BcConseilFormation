require "cgi"

# Génère les modules pédagogiques d'un support en arrière-plan.
# Enqueued par GenerateurController#generer_modules (POST async → 202).
# Résultat écrits en base ; statut dans cours_support.programme_json["ia"]["modules"].
class LmsGenerateurJob < ApplicationJob
  queue_as :ia

  retry_on StandardError, wait: :polynomially_longer, attempts: 2
  discard_on ActiveRecord::RecordNotFound

  def perform(support_id:, nb_modules:, user_id:)
    support = CoursSupport.find(support_id)
    ia_set(support, "modules", "en_cours")

    contenu = support.extraire_texte
    raise "Le support ne contient pas de texte extractible." if contenu.blank?

    service      = LmsGenerateurService.new(contenu: contenu, nb_modules: nb_modules)
    modules_data = service.generer_modules

    # Supprimer les modules IA précédents (régénération propre)
    support.module_formations.where(user_id: user_id).destroy_all

    modules_data.each_with_index do |mod_data, idx|
      sections_html = Array(mod_data["sections"]).map do |s|
        "<h3>#{CGI.escapeHTML(s["titre"].to_s)}</h3>\n#{s["contenu"]}"
      end.join("\n\n")

      support.module_formations.create!(
        titre:         mod_data["titre"].to_s,
        objectifs:     Array(mod_data["objectifs"]),
        duree_estimee: mod_data["duree_estimee"].to_s,
        contenu:       sections_html,
        ordre:         idx,
        user_id:       user_id
      )
    end

    ia_set(support, "modules", "ok")
  rescue => e
    ia_set(support, "modules", "erreur", e.message) if support
    raise
  end

  private

  def ia_set(support, cle, statut, erreur = nil)
    pj = support.programme_json.deep_dup
    pj["ia"] ||= {}
    pj["ia"][cle] = { "statut" => statut, "maj_le" => Time.current.iso8601, "erreur" => erreur }
    support.update_columns(programme_json: pj)
  end
end
