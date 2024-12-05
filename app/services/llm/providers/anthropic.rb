module LLM
  module Providers
    class Anthropic < BaseProvider
      def initialize(config = {})
        super
        @client = ::Anthropic::Client.new(
          access_token: config.dig(:anthropic, :api_key)
        )
      end

      def chat(messages:, system_prompt: nil, max_tokens: 1000, response_format: nil)
        params = {
          model: config.dig(:anthropic, :model),
          messages: messages.map { |msg| format_message(msg) },
          max_tokens: max_tokens
        }

        params[:system] = system_prompt if system_prompt
        
        # Handle JSON response format if needed
        if response_format&.dig(:type) == "json_schema"
          params[:system] = [
            system_prompt,
            "You MUST respond with valid JSON that follows this schema:",
            response_format[:json_schema].to_json
          ].compact.join("\n\n")
        end

        response = @client.messages(parameters: params)
        response.content
      end

      def generate_image(prompt:, size: "1024x1024", quality: "standard", n: 1)
        raise NotImplementedError, "Anthropic does not support image generation"
      end

      private

      def format_message(msg)
        {
          role: msg[:role] == "assistant" ? "assistant" : "user",
          content: msg[:content]
        }
      end
    end
  end
end 