require "openai"
require "json"

# LmsGenerateurService
# Appelle l'API OpenAI pour générer modules et quiz à partir d'un support de cours.
#
# Usage :
#   service = LmsGenerateurService.new(contenu: "...texte du cours...", nb_modules: 3)
#   result  = service.generer_modules   # => Array de hashes
#   result  = service.generer_quiz(module_contenu: "...") # => Array de hashes
#
class LmsGenerateurService
  MODEL   = "gpt-4o-mini"
  TIMEOUT = 60

  def initialize(contenu:, nb_modules: 3, nb_questions: 5, langue: "fr")
    @contenu      = contenu.to_s.strip.truncate(12_000)
    @nb_modules   = nb_modules.to_i.clamp(1, 8)
    @nb_questions = nb_questions.to_i.clamp(3, 15)
    @langue       = langue
    @client       = OpenAI::Client.new(
      access_token:    ENV["OPENAI_API_KEY"] || Rails.application.credentials.openai_api_key,
      request_timeout: TIMEOUT
    )
  end

  # Retourne un Array de hashes :
  # [{ titre, objectifs, duree_estimee, contenu_html, sections }, ...]
  def generer_modules
    prompt = <<~PROMPT
      Tu es un expert en ingénierie pédagogique et formation professionnelle.
      À partir du support de cours ci-dessous, génère #{@nb_modules} module(s) de formation structurés.

      Retourne UNIQUEMENT un tableau JSON valide avec la structure suivante pour chaque module :
      [
        {
          "titre": "Titre du module",
          "objectifs": ["Objectif 1", "Objectif 2", "Objectif 3"],
          "duree_estimee": "1h30",
          "sections": [
            { "titre": "Titre section", "contenu": "Contenu détaillé en HTML simple (<p>, <ul>, <strong>)" }
          ]
        }
      ]

      Règles :
      - Langue : #{@langue}
      - Titres clairs et orientés compétences
      - 3 objectifs pédagogiques minimum par module (verbes d'action : comprendre, appliquer, analyser…)
      - 2 à 4 sections par module avec contenu substantiel
      - Format HTML simple uniquement pour les sections (pas de style inline)
      - Pas de texte en dehors du JSON

      SUPPORT DE COURS :
      #{@contenu}
    PROMPT

    call_api(prompt)
  end

  # Retourne un Array de hashes :
  # [{ enonce, options, bonne_reponse, explication }, ...]
  def generer_quiz(module_contenu:)
    texte = module_contenu.to_s.truncate(6_000)

    prompt = <<~PROMPT
      Tu es un expert en création de quiz pédagogiques.
      À partir du contenu de module ci-dessous, génère #{@nb_questions} questions à choix multiples (QCM).

      Retourne UNIQUEMENT un tableau JSON valide :
      [
        {
          "enonce": "Question posée clairement",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "bonne_reponse": 0,
          "explication": "Explication courte de la bonne réponse"
        }
      ]

      Règles :
      - Langue : #{@langue}
      - `bonne_reponse` est l'index (0-based) de la bonne option dans `options`
      - 4 options par question, une seule bonne réponse
      - Questions variées (définition, application, cas pratique)
      - Pas de texte en dehors du JSON

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
        temperature: 0.6,
        max_tokens:  4096
      }
    )

    raw = response.dig("choices", 0, "message", "content").to_s.strip
    # Nettoyer les balises markdown si présentes
    raw = raw.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip

    JSON.parse(raw)
  rescue JSON::ParserError => e
    Rails.logger.error "LmsGenerateurService JSON parse error: #{e.message}\nRaw: #{raw}"
    raise "La réponse IA n'est pas au format JSON valide. Réessayez."
  rescue OpenAI::Error => e
    Rails.logger.error "LmsGenerateurService OpenAI error: #{e.message}"
    raise "Erreur API OpenAI : #{e.message}"
  end
end
