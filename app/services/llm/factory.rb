module LLM
  class Factory
    class << self
      def create_provider
        provider_class = LLMConfig.provider_class
        provider_class.new(LLMConfig.config)
      end

      def create_image_provider
        LLM::Providers::OpenAI.new(LLMConfig.config)
      end
    end
  end
end 