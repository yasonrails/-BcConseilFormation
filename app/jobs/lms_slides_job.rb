# Génère les slides d'un support en arrière-plan.
# Enqueued par GenerateurController#generer_slides (POST async → 202).
# Résultat stocké dans cours_support.programme_json["slides"].
# Statut dans cours_support.programme_json["ia"]["slides"].
class LmsSlidesJob < ApplicationJob
  queue_as :ia

  retry_on StandardError, wait: :polynomially_longer, attempts: 2
  discard_on ActiveRecord::RecordNotFound

  def perform(support_id:, nb_slides:)
    support = CoursSupport.find(support_id)
    ia_set(support, "slides", "en_cours")

    contenu = support.extraire_texte
    raise "Le support ne contient pas de texte extractible." if contenu.blank?

    service = LmsSlidesService.new(contenu: contenu, nb_slides: nb_slides)
    slides  = service.generer_slides

    pj = support.programme_json.deep_dup
    pj["slides"] = slides
    pj["ia"]     ||= {}
    pj["ia"]["slides"] = { "statut" => "ok", "maj_le" => Time.current.iso8601, "erreur" => nil, "count" => slides.size }
    support.update_columns(programme_json: pj)
  rescue => e
    ia_set(support, "slides", "erreur", e.message) if support
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
