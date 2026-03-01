require "openai"
require "json"

# LmsSlidesService
# Génère une présentation slide-by-slide depuis un support (PDF / PPTX / texte).
# Indépendant du générateur de modules et du quiz.
#
class LmsSlidesService
  MODEL   = "gpt-4o-mini"
  TIMEOUT = 90

  def initialize(contenu:, nb_slides: 8, langue: "fr")
    @contenu   = contenu.to_s.strip.truncate(14_000)
    @nb_slides = nb_slides.to_i.clamp(4, 20)
    @langue    = langue
    @client    = OpenAI::Client.new(
      access_token:    ENV["OPENAI_API_KEY"] || Rails.application.credentials.openai_api_key,
      request_timeout: TIMEOUT
    )
  end

  def generer_slides
    prompt = <<~PROMPT
      Tu es un expert en conception de présentations pédagogiques.
      À partir du contenu ci-dessous (extrait de PDF ou PowerPoint), génère #{@nb_slides} slides de présentation.

      Retourne UNIQUEMENT un tableau JSON :
      [
        {
          "ordre": 1,
          "type": "titre",
          "titre": "Titre principal de la formation",
          "sous_titre": "Sous-titre ou accroche",
          "notes": "Notes du formateur (optionnel)"
        },
        {
          "ordre": 2,
          "type": "objectifs",
          "titre": "Objectifs de la formation",
          "items": ["À l'issue de cette formation, vous serez capable de…", "Objectif 2", "Objectif 3"],
          "notes": ""
        },
        {
          "ordre": 3,
          "type": "contenu",
          "titre": "Titre de la slide",
          "items": ["Point clé 1", "Point clé 2", "Point clé 3"],
          "details": "Paragraphe de contexte ou définition (2-3 phrases max)",
          "notes": "Note formateur"
        },
        {
          "ordre": 4,
          "type": "definition",
          "titre": "Concept clé",
          "definition": "Définition concise et claire",
          "exemple": "Exemple concret",
          "notes": ""
        },
        {
          "ordre": 5,
          "type": "cas_pratique",
          "titre": "Mise en situation",
          "scenario": "Description d'un cas pratique réaliste",
          "questions": ["Question de réflexion 1", "Question 2"],
          "notes": ""
        },
        {
          "ordre": 99,
          "type": "conclusion",
          "titre": "Points clés à retenir",
          "items": ["Point 1", "Point 2", "Point 3"],
          "cta": "Action à mettre en place dès demain",
          "notes": ""
        }
      ]

      Types disponibles : "titre" | "objectifs" | "contenu" | "definition" | "cas_pratique" | "chiffre_cle" | "citation" | "conclusion"
      Pour "chiffre_cle" : ajouter "chiffre" (ex: "73%") et "legende".
      Pour "citation" : ajouter "citation" et "auteur".

      Règles :
      - Langue : #{@langue}
      - Première slide : type "titre"
      - Deuxième slide : type "objectifs"
      - Dernière slide : type "conclusion"
      - Varier les types pour éviter la monotonie
      - Items courts (max 10 mots chacun)
      - Cas pratiques ancrés dans la réalité professionnelle
      - JSON seul, pas d'autre texte

      CONTENU SOURCE :
      #{@contenu}
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
    Rails.logger.error "LmsSlidesService JSON parse error: #{e.message}\nRaw: #{raw}"
    raise "La réponse IA n'est pas au format JSON valide. Réessayez."
  rescue OpenAI::Error => e
    Rails.logger.error "LmsSlidesService OpenAI error: #{e.message}"
    raise "Erreur API OpenAI : #{e.message}"
  end
end
