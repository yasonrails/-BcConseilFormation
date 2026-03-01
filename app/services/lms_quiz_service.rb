require "openai"
require "json"

# LmsQuizService
# Génère un QCM interactif et engageant à partir du contenu d'un module.
# Indépendant du générateur de modules et du générateur de slides.
#
class LmsQuizService
  MODEL   = "gpt-4o-mini"
  TIMEOUT = 90

  def initialize(nb_questions: 7, langue: "fr")
    @nb_questions = nb_questions.to_i.clamp(3, 10)
    @langue       = langue
    @client       = OpenAI::Client.new(
      access_token:    ENV["OPENAI_API_KEY"] || Rails.application.credentials.openai_api_key,
      request_timeout: TIMEOUT
    )
  end

  # module_contenu : le texte ou HTML du module à évaluer
  def generer_quiz(module_contenu:)
    texte = module_contenu.to_s.truncate(7_000)
    nb    = @nb_questions

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
    call_api(prompt)
  end

  private

  def call_api(prompt)
    response = @client.chat(
      parameters: {
        model:       MODEL,
        messages:    [{ role: "user", content: prompt }],
        temperature: 0.65,
        max_tokens:  4096
      }
    )

    raw = response.dig("choices", 0, "message", "content").to_s.strip
    raw = raw.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip

    JSON.parse(raw)
  rescue JSON::ParserError => e
    Rails.logger.error "LmsQuizService JSON parse error: #{e.message}\nRaw: #{raw}"
    raise "La réponse IA n'est pas au format JSON valide. Réessayez."
  rescue OpenAI::Error => e
    Rails.logger.error "LmsQuizService OpenAI error: #{e.message}"
    raise "Erreur API OpenAI : #{e.message}"
  end
end
