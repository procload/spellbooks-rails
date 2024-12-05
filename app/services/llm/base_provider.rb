module LLM
  class BaseProvider
    def initialize(config = {})
      @config = config
    end

    def chat(messages:, system_prompt: nil, max_tokens: 1000, response_format: nil)
      raise NotImplementedError, "#{self.class} must implement #chat"
    end

    def generate_image(prompt:, size: "1024x1024", quality: "standard", n: 1)
      raise NotImplementedError, "#{self.class} must implement #generate_image"
    end

    private

    attr_reader :config
  end
end 