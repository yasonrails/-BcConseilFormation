require "net/http"
require "json"

# AiProvider::Ollama
# LLM local via Ollama (https://ollama.ai)
# Lance Ollama en local : `ollama serve` puis `ollama pull mistral`
# Compatible tout modèle Ollama : mistral, llama3, mixtral, phi3, gemma2, etc.
#
# Config :
#   AI_PROVIDER=ollama
#   OLLAMA_URL=http://localhost:11434   (défaut)
#   OLLAMA_MODEL=mistral                (défaut)
#
module AiProvider
  class Ollama < Base
    DEFAULT_URL     = "http://localhost:11434"
    DEFAULT_MODEL   = "mistral"
    REQUEST_TIMEOUT = 120   # Les modèles locaux peuvent être lents au 1er token

    def initialize(config = {})
      super
      @model   = config.fetch(:model, ENV.fetch("OLLAMA_MODEL", DEFAULT_MODEL))
      @base_url = config.fetch(:url,  ENV.fetch("OLLAMA_URL",   DEFAULT_URL)).chomp("/")
    end

    def chat(prompt, max_tokens: @config[:max_tokens], temperature: @config[:temperature])
      uri  = URI("#{@base_url}/api/chat")
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = REQUEST_TIMEOUT

      body = {
        model:  @model,
        stream: false,
        options: { temperature: temperature, num_predict: max_tokens },
        messages: [{ role: "user", content: prompt }]
      }

      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = body.to_json

      response = http.request(request)
      data     = JSON.parse(response.body)

      raise ProviderError, data["error"] if data["error"]

      data.dig("message", "content").to_s
    rescue Errno::ECONNREFUSED
      raise ProviderError, "Ollama non démarré. Lance `ollama serve` localement."
    rescue Net::TimeoutError => e
      raise ProviderError, "Timeout Ollama (#{REQUEST_TIMEOUT}s) — modèle trop lourd ou machine lente."
    rescue => e
      Rails.logger.error "[Ollama] #{e.message}"
      raise ProviderError, "Erreur Ollama : #{e.message}"
    end

    # Liste les modèles installés localement
    def models_disponibles
      uri  = URI("#{@base_url}/api/tags")
      resp = Net::HTTP.get(uri)
      JSON.parse(resp).fetch("models", []).map { |m| m["name"] }
    rescue
      %w[mistral llama3 mixtral phi3 gemma2]
    end

    # Vérifie si Ollama est joignable
    def disponible?
      uri  = URI("#{@base_url}/api/tags")
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 2
      http.get(uri.path)
      true
    rescue
      false
    end
  end
end
