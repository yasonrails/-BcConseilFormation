# AiProvider::Base
# Interface commune pour tous les fournisseurs LLM.
# Tout provider doit implémenter #chat(prompt, max_tokens:, temperature:) → String
#
module AiProvider
  class Base
    class ProviderError < StandardError; end
    class ConfigurationError < StandardError; end

    DEFAULTS = {
      temperature: 0.65,
      max_tokens:  4096
    }.freeze

    def initialize(config = {})
      @config = DEFAULTS.merge(config)
      validate_config!
    end

    # @param prompt [String]
    # @param max_tokens [Integer]
    # @param temperature [Float]
    # @return [String] — texte brut de la réponse
    def chat(prompt, max_tokens: @config[:max_tokens], temperature: @config[:temperature])
      raise NotImplementedError, "#{self.class}#chat non implémenté"
    end

    # Parsing JSON commun à tous les providers
    def chat_json(prompt, **opts)
      raw = chat(prompt, **opts).strip
      raw = raw.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip
      JSON.parse(raw)
    rescue JSON::ParserError => e
      Rails.logger.error "[#{provider_name}] JSON parse error: #{e.message}\nRaw: #{raw}"
      raise ProviderError, "Réponse IA invalide (JSON attendu). Réessayez."
    end

    def provider_name
      self.class.name.demodulize
    end

    private

    def validate_config!
      # surcharger dans les sous-classes pour valider les credentials
    end
  end
end
