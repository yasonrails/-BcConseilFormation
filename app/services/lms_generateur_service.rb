require "openai"
require "json"

# LmsGenerateurService
# Génère la structure pédagogique complète d'une formation (modules, objectifs, sections).
# Pour les slides → LmsSlidesService / Pour le quiz → LmsQuizService
#
class LmsGenerateurService
  MODEL   = "gpt-4o-mini"
  TIMEOUT = 90

  def initialize(contenu:, nb_modules: 3, langue: "fr")
    @contenu    = contenu.to_s.strip.truncate(14_000)
    @nb_modules = nb_modules.to_i.clamp(1, 8)
    @langue     = langue
    @client     = OpenAI::Client.new(
      access_token:    ENV["OPENAI_API_KEY"] || Rails.application.credentials.openai_api_key,
      request_timeout: TIMEOUT
    )
  end

  def generer_modules
    prompt = <<~PROMPT
      Tu es un expert en ingénierie pédagogique et formation professionnelle.
      À partir du support ci-dessous, génère #{@nb_modules} module(s) de formation structurés.

      Retourne UNIQUEMENT un tableau JSON :
      [
        {
          "titre": "Titre du module",
          "objectifs": ["Objectif 1 (verbe d'action)", "Objectif 2", "Objectif 3"],
          "duree_estimee": "1h30",
          "sections": [
            { "titre": "Section 1", "contenu": "<p>Contenu HTML simple</p><ul><li>Point</li></ul>" }
          ]
        }
      ]

      Règles : langue #{@langue} · 3 objectifs minimum · verbes d'action · 2-4 sections · HTML simple · JSON seul.

      SUPPORT :
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
    Rails.logger.error "LmsGenerateurService JSON parse error: #{e.message}\nRaw: #{raw}"
    raise "La réponse IA n'est pas au format JSON valide. Réessayez."
  rescue OpenAI::Error => e
    Rails.logger.error "LmsGenerateurService OpenAI error: #{e.message}"
    raise "Erreur API OpenAI : #{e.message}"
  end
end
