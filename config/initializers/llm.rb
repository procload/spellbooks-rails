module LLMConfig
  mattr_accessor :provider
  mattr_accessor :config

  def self.configure
    yield self
  end

  def self.provider_class
    case provider.to_sym
    when :openai
      LLM::Providers::OpenAI
    when :anthropic
      LLM::Providers::Anthropic
    else
      raise "Unknown LLM provider: #{provider}"
    end
  end
end

# Default configuration
LLMConfig.configure do |config|
  config.provider = Rails.application.credentials.dig(:llm, :provider) || :openai
  config.config = {
    openai: {
      api_key: Rails.application.credentials.dig(:openai, :api_key),
      model: "gpt-4-0125-preview",
      timeout: 240
    },
    anthropic: {
      api_key: Rails.application.credentials.dig(:anthropic, :api_key),
      model: "claude-3-haiku-20240307",
      timeout: 240
    }
  }
end
