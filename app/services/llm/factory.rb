module LLM
  class Factory
    def self.create_provider
      provider_class = LLMConfig.provider_class
      provider_class.new(LLMConfig.config)
    end

    def self.create_image_provider
      # For now, we only support OpenAI for image generation
      LLM::Providers::OpenAI.new(LLMConfig.config)
    end
  end
end 