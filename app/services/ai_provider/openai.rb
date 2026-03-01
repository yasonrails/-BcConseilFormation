require "openai"

# AiProvider::Openai
# Fournisseur cloud OpenAI (gpt-4o, gpt-4o-mini, etc.)
#
module AiProvider
  class Openai < Base
    DEFAULT_MODEL   = "gpt-4o-mini"
    REQUEST_TIMEOUT = 90

    def initialize(config = {})
      super
      @model  = config.fetch(:model, DEFAULT_MODEL)
      @client = ::OpenAI::Client.new(
        access_token:    api_key,
        request_timeout: REQUEST_TIMEOUT
      )
    end

    def chat(prompt, max_tokens: @config[:max_tokens], temperature: @config[:temperature])
      response = @client.chat(
        parameters: {
          model:       @model,
          messages:    [{ role: "user", content: prompt }],
          temperature: temperature,
          max_tokens:  max_tokens
        }
      )
      response.dig("choices", 0, "message", "content").to_s
    rescue ::OpenAI::Error => e
      Rails.logger.error "[Openai] #{e.message}"
      raise ProviderError, "Erreur API OpenAI : #{e.message}"
    end

    def models_disponibles
      %w[gpt-4o gpt-4o-mini gpt-4-turbo gpt-3.5-turbo]
    end

    private

    def api_key
      key = ENV["OPENAI_API_KEY"].presence ||
            Rails.application.credentials.dig(:openai, :api_key).presence
      raise ConfigurationError, "OPENAI_API_KEY manquante" unless key
      key
    end

    def validate_config!
      api_key # lève ConfigurationError si absente
    end
  end
end
