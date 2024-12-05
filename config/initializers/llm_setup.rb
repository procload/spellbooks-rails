# Load all LLM-related files
Dir[Rails.root.join('app', 'services', 'llm', '**', '*.rb')].sort.each do |file|
  require file
end

# Configure LLM settings
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