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

      def test_connection
        params = {
          model: "gpt-4o-2024-08-06",
          messages: [
            { role: "user", content: "Say hello" }
          ]
        }

        Rails.logger.info "[OpenAI Provider] Test request params: #{params.inspect}"
        
        begin
          response = @client.chat(parameters: params)
          Rails.logger.info "[OpenAI Provider] Test response: #{response.inspect}"
          response.dig("choices", 0, "message", "content")
        rescue StandardError => e
          Rails.logger.error "[OpenAI Provider] Test error: #{e.class} - #{e.message}"
          if e.respond_to?(:response)
            Rails.logger.error "[OpenAI Provider] Test response status: #{e.response[:status]}"
            Rails.logger.error "[OpenAI Provider] Test response body: #{e.response[:body]}"
          end
          raise
        end
      end

      def test_json_schema
        params = {
          model: "gpt-4o-2024-08-06",
          messages: [
            { 
              role: "system", 
              content: "You are a math question generator. Respond with a JSON object containing a question and its numerical answer."
            },
            { 
              role: "user", 
              content: "Generate one simple math question" 
            }
          ],
          response_format: { type: "json_object" }
        }

        Rails.logger.info "[OpenAI Provider] Test JSON params: #{params.inspect}"
        
        begin
          response = @client.chat(parameters: params)
          Rails.logger.info "[OpenAI Provider] Test JSON response: #{response.inspect}"
          response.dig("choices", 0, "message", "content")
        rescue StandardError => e
          Rails.logger.error "[OpenAI Provider] Test JSON error: #{e.class} - #{e.message}"
          if e.respond_to?(:response)
            Rails.logger.error "[OpenAI Provider] Test JSON response status: #{e.response[:status]}"
            Rails.logger.error "[OpenAI Provider] Test JSON response body: #{e.response[:body]}"
          end
          raise
        end
      end

      def chat(messages:, system_prompt: nil, max_tokens: 8192, response_format: nil)
        params = {
          model: "gpt-4o-2024-08-06",
          max_tokens: max_tokens,
          messages: []
        }

        # Add response format if provided
        params[:response_format] = response_format if response_format

        # Add system prompt if provided
        params[:messages] << { role: "system", content: system_prompt } if system_prompt

        # Add user messages
        messages = Array(messages).map do |msg|
          msg.is_a?(Hash) ? msg : { role: "user", content: msg.to_s }
        end
        params[:messages].concat(messages)

        Rails.logger.info "[OpenAI Provider] Request params: #{params.inspect}"
        
        begin
          response = @client.chat(parameters: params)
          Rails.logger.info "[OpenAI Provider] Response: #{response.inspect}"
          content = response.dig("choices", 0, "message", "content")
          
          if response_format&.dig(:type) == "json_object"
            begin
              JSON.parse(content, symbolize_names: true)
            rescue JSON::ParserError => e
              raise LLM::Error, "Failed to parse JSON response: #{e.message}"
            end
          else
            content
          end
        rescue StandardError => e
          Rails.logger.error "[OpenAI Provider] Error: #{e.class} - #{e.message}"
          if e.respond_to?(:response)
            Rails.logger.error "[OpenAI Provider] Response status: #{e.response[:status]}"
            Rails.logger.error "[OpenAI Provider] Response body: #{e.response[:body]}"
          end
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