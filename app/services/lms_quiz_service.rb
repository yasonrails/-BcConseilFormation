# LmsQuizService
# Génère un QCM interactif et engageant à partir du contenu d'un module.
# Le provider IA est sélectionné via AiProvider::Registry (ENV AI_PROVIDER ou credentials).
# Indépendant du générateur de modules et du générateur de slides.
#
class LmsQuizService
  def initialize(nb_questions: 7, langue: "fr")
    @nb_questions = nb_questions.to_i.clamp(3, 10)
    @langue       = langue
    @ai           = AiProvider::Registry.build
  end

  # module_contenu : le texte ou HTML du module à évaluer
  def generer_quiz(module_contenu:)
    texte  = module_contenu.to_s.truncate(7_000)
    nb     = @nb_questions
    prompt = <<~PROMPT
      Tu es un expert en gamification pédagogique et psychologie de l'apprentissage.
      Génère #{nb} questions interactives et engageantes à partir du contenu ci-dessous.
      Limite : #{nb} questions maximum (respecte la concentration humaine — pas plus).

      Retourne UNIQUEMENT un tableau JSON :
      [
        {
          "type": "qcm",
          "niveau": "decouverte",
          "enonce": "Question claire et précise",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "bonne_reponse": 0,
          "explication": "Explication pédagogique de la bonne réponse",
          "pourquoi": "Pourquoi c'est important dans la pratique professionnelle",
          "point_cle": "Le concept essentiel à retenir"
        },
        {
          "type": "vrai_faux",
          "niveau": "comprehension",
          "enonce": "Affirmation à évaluer",
          "options": ["Vrai", "Faux"],
          "bonne_reponse": 0,
          "explication": "…",
          "pourquoi": "…",
          "point_cle": "…"
        },
        {
          "type": "scenario",
          "niveau": "application",
          "enonce": "Situation : [contexte professionnel réaliste]. Que faites-vous ?",
          "options": ["Action A", "Action B", "Action C", "Action D"],
          "bonne_reponse": 2,
          "explication": "…",
          "pourquoi": "…",
          "point_cle": "…"
        }
      ]

      Niveaux disponibles : "decouverte" | "comprehension" | "application"
      Distribution recommandée : 30% découverte · 40% compréhension · 30% application
      Types : au moins 1 "vrai_faux", au moins 2 "scenario", reste en "qcm"

      Règles :
      - Langue : #{@langue}
      - Énoncer clairement, sans ambiguïté
      - Pour les scénarios : ancrer dans des situations RH/management réelles
      - "pourquoi" : 1 phrase, impact professionnel concret
      - "point_cle" : 5 mots max, concept mémorisable
      - bonne_reponse : index 0-based
      - JSON seul

      CONTENU DU MODULE :
      #{texte}
    PROMPT
    @ai.chat_json(prompt)
  rescue AiProvider::Base::ProviderError => e
    Rails.logger.error "LmsQuizService: #{e.message}"
    raise
  end
end
