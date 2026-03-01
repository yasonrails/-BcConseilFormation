require "net/http"
require "json"

# AiProvider::Anthropic
# Fournisseur cloud Anthropic Claude (claude-3-5-sonnet, claude-3-haiku, etc.)
# API : https://api.anthropic.com/v1/messages
#
module AiProvider
  class Anthropic < Base
    DEFAULT_MODEL   = "claude-3-5-haiku-20241022"
    API_URL         = "https://api.anthropic.com/v1/messages"
    API_VERSION     = "2023-06-01"
    REQUEST_TIMEOUT = 90

    def initialize(config = {})
      super
      @model = config.fetch(:model, DEFAULT_MODEL)
    end

    def chat(prompt, max_tokens: @config[:max_tokens], temperature: @config[:temperature])
      uri  = URI(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.read_timeout = REQUEST_TIMEOUT

      body = {
        model:      @model,
        max_tokens: max_tokens,
        messages:   [{ role: "user", content: prompt }]
      }

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"]      = "application/json"
      request["x-api-key"]         = api_key
      request["anthropic-version"] = API_VERSION
      request.body = body.to_json

      response = http.request(request)
      data = JSON.parse(response.body)

      raise ProviderError, data.dig("error", "message") if data["error"]

      data.dig("content", 0, "text").to_s
    rescue Net::TimeoutError => e
      raise ProviderError, "Timeout Anthropic : #{e.message}"
    rescue => e
      Rails.logger.error "[Anthropic] #{e.message}"
      raise ProviderError, "Erreur API Anthropic : #{e.message}"
    end

    def models_disponibles
      %w[claude-3-5-sonnet-20241022 claude-3-5-haiku-20241022 claude-3-opus-20240229]
    end

    private

    def api_key
      key = ENV["ANTHROPIC_API_KEY"].presence ||
            Rails.application.credentials.dig(:anthropic, :api_key).presence
      raise ConfigurationError, "ANTHROPIC_API_KEY manquante" unless key
      key
    end

    def validate_config!
      api_key
    end
  end
end
