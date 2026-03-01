# Génère les questions de quiz d'un module en arrière-plan.
# Enqueued par GenerateurController#generer_quiz (POST async → 202).
# Statut dans cours_support.programme_json["ia"]["quiz"]["<module_id>"].
class LmsQuizJob < ApplicationJob
  queue_as :ia

  retry_on StandardError, wait: :polynomially_longer, attempts: 2
  discard_on ActiveRecord::RecordNotFound

  def perform(support_id:, module_id:, nb_questions:)
    support = CoursSupport.find(support_id)
    mod     = support.module_formations.find(module_id)
    ia_set(support, module_id, "en_cours")

    service        = LmsQuizService.new(nb_questions: nb_questions)
    questions_data = service.generer_quiz(module_contenu: mod.contenu.to_s)

    # Régénération propre
    mod.quiz_questions.destroy_all

    questions_data.each_with_index do |q, idx|
      mod.quiz_questions.create!(
        enonce:        q["enonce"].to_s,
        options:       Array(q["options"]),
        bonne_reponse: q["bonne_reponse"].to_i,
        explication:   q["explication"].to_s,
        type_question: q["type"].to_s.presence || "qcm",
        niveau:        q["niveau"].to_s.presence || "comprehension",
        pourquoi:      q["pourquoi"].to_s,
        point_cle:     q["point_cle"].to_s,
        ordre:         idx
      )
    end

    ia_set(support, module_id, "ok", nil, questions_data.size)
  rescue => e
    ia_set(support, module_id, "erreur", e.message) if support
    raise
  end

  private

  def ia_set(support, module_id, statut, erreur = nil, count = nil)
    pj = support.programme_json.deep_dup
    pj["ia"]         ||= {}
    pj["ia"]["quiz"] ||= {}
    pj["ia"]["quiz"][module_id.to_s] = {
      "statut" => statut,
      "maj_le" => Time.current.iso8601,
      "erreur" => erreur,
      "count"  => count
    }
    support.update_columns(programme_json: pj)
  end
end
