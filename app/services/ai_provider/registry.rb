# AiProvider::Registry
# Sélectionne et instancie le bon provider selon la config.
#
# Source de vérité (par priorité) :
#   1. Argument explicite   → AiProvider::Registry.build(:ollama)
#   2. Variable ENV         → AI_PROVIDER=anthropic
#   3. Credentials Rails    → credentials.ai_provider = "openai"
#   4. Défaut               → openai
#
# Basculer en local :
#   export AI_PROVIDER=ollama
#   export OLLAMA_MODEL=mistral
#
# Basculer sur Anthropic :
#   export AI_PROVIDER=anthropic
#   export ANTHROPIC_API_KEY=sk-ant-...
#
module AiProvider
  module Registry
    PROVIDERS = {
      "openai"    => -> (cfg) { AiProvider::Openai.new(cfg) },
      "anthropic" => -> (cfg) { AiProvider::Anthropic.new(cfg) },
      "ollama"    => -> (cfg) { AiProvider::Ollama.new(cfg) }
    }.freeze

    # @param name [String, Symbol, nil] — force un provider spécifique
    # @param config [Hash] — options passées au provider (model:, url:, etc.)
    # @return [AiProvider::Base]
    def self.build(name = nil, config = {})
      key = resolve_name(name)
      factory = PROVIDERS[key] or raise AiProvider::Base::ConfigurationError,
        "Provider IA inconnu : '#{key}'. Disponibles : #{PROVIDERS.keys.join(', ')}"
      factory.call(config)
    end

    # Provider par défaut (sans argument)
    def self.default
      build
    end

    def self.available_names
      PROVIDERS.keys
    end

    private

    def self.resolve_name(name)
      (name&.to_s ||
       ENV["AI_PROVIDER"].presence ||
       Rails.application.credentials.dig(:ai_provider).presence ||
       "openai").downcase
    end
  end
end
