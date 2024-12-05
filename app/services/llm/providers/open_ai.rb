module LLM
  module Providers
    class OpenAI < BaseProvider
      def initialize(config = {})
        super
        @client = ::OpenAI::Client.new(
          access_token: config.dig(:openai, :api_key),
          request_timeout: config.dig(:openai, :timeout) || 240
        )
      end

      def chat(messages:, system_prompt: nil, max_tokens: 1000, response_format: nil)
        params = {
          model: "gpt-4o-2024-08-06",
          messages: [
            { 
              role: "system", 
              content: system_prompt 
            },
            *messages
          ],
          response_format: {
            type: "json_schema",
            json_schema: {
              "strict": true,
              "name": "Assignment",
              "description": "Generates an educational assignment",
              "schema": ::ASSIGNMENT_SCHEMA
            }
          }
        }

        Rails.logger.info "[OpenAI Provider] Request params: #{params.except(:messages).inspect}"
        Rails.logger.info "[OpenAI Provider] System prompt: #{system_prompt}"
        Rails.logger.info "[OpenAI Provider] Message count: #{messages.length}"
        
        begin
          response = @client.chat(parameters: params)
          Rails.logger.info "[OpenAI Provider] Response status: Success"
          response.dig("choices", 0, "message", "content")
        rescue Faraday::Error => e
          Rails.logger.error "[OpenAI Provider] HTTP Error: #{e.class} - #{e.message}"
          if e.response
            Rails.logger.error "[OpenAI Provider] Response status: #{e.response[:status]}"
            Rails.logger.error "[OpenAI Provider] Response body: #{e.response[:body]}"
          end
          raise
        rescue StandardError => e
          Rails.logger.error "[OpenAI Provider] Unexpected error: #{e.class} - #{e.message}"
          Rails.logger.error "[OpenAI Provider] Backtrace: #{e.backtrace.join("\n")}"
          raise
        end
      end

      def generate_image(prompt:, size: "1024x1024", quality: "standard", n: 1)
        begin
          response = @client.images.generate(
            parameters: {
              model: "dall-e-3",
              prompt: prompt,
              size: size,
              quality: quality,
              n: n
            }
          )
          
          Rails.logger.info "[OpenAI Provider] Image generation successful"
          response.dig("data", 0, "url")
        rescue StandardError => e
          Rails.logger.error "[OpenAI Provider] Image generation error: #{e.class} - #{e.message}"
          if e.respond_to?(:response) && e.response
            Rails.logger.error "[OpenAI Provider] Response status: #{e.response[:status]}"
            Rails.logger.error "[OpenAI Provider] Response body: #{e.response[:body]}"
          end
          raise
        end
      end
    end
  end
end 