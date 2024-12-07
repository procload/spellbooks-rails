module LLM
  module Providers
    class Anthropic < BaseProvider
      ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages'.freeze
      ANTHROPIC_API_VERSION = '2023-06-01'.freeze

      AVAILABLE_MODELS = {
        sonnet_latest: 'claude-3-5-sonnet-latest',
        opus: 'claude-3-opus-20240229',
        haiku: 'claude-3-haiku-20240307'
      }.freeze

      def initialize(config = {})
        super

        anthropic_config = config[:anthropic] || {}
        Rails.logger.info "[Anthropic Provider] Provider config: #{anthropic_config.inspect}"

        @model = anthropic_config[:model] || AVAILABLE_MODELS[:sonnet_latest]
        @api_key = anthropic_config[:api_key]

        Rails.logger.info "[Anthropic Provider] Using model: #{@model}"
        Rails.logger.info "[Anthropic Provider] API key present: #{!@api_key.nil?}"
        Rails.logger.info "[Anthropic Provider] Using API version: #{ANTHROPIC_API_VERSION}"

        @conn = Faraday.new(url: ANTHROPIC_API_URL) do |f|
          f.request :json
          f.response :json
          f.adapter Faraday.default_adapter
        end
      end

      def tool_input_schema
        {
          "$schema" => "http://json-schema.org/draft-07/schema#",
          "type" => "object",
          "properties" => {
            "passage" => {
              "type" => "string",
              "description" => "The reading passage for the assignment"
            },
            "questions" => {
              "type" => "array",
              "items" => {
                "type" => "object",
                "required" => ["question_text", "answers", "explanation"],
                "properties" => {
                  "question_text" => {
                    "type" => "string",
                    "description" => "The text of the question"
                  },
                  "answers" => {
                    "type" => "array",
                    "items" => {
                      "type" => "object",
                      "required" => ["text", "is_correct"],
                      "properties" => {
                        "text" => {
                          "type" => "string",
                          "description" => "The text of the answer option"
                        },
                        "is_correct" => {
                          "type" => "boolean",
                          "description" => "Whether this is the correct answer"
                        }
                      },
                      "additionalProperties" => false
                    }
                  },
                  "explanation" => {
                    "type" => "string",
                    "description" => "Explanation of why the correct answer is correct"
                  }
                },
                "additionalProperties" => false
              }
            }
          },
          "required" => ["passage", "questions"],
          "additionalProperties" => false
        }
      end

     def test_connection(title: "Learning about science",
                    grade_level: "9",
                    difficulty: "Medium",
                    interests: "space and astronomy",
                    num_questions: 3)
  Rails.logger.info "[Anthropic Provider] Testing assignment generation..."

	prompt = <<~PROMPT
	Create an assignment with the following parameters:
	Title: "#{title}"
	Grade Level: "#{grade_level}"
	Difficulty: "#{difficulty}"
	Interests: "#{interests}"
	Number of Questions: "#{num_questions}"

	Generate content that:
	- Provides an age-appropriate reading passage
	- Contains exactly "#{num_questions}" questions
	- Incorporates themes related to "#{interests}"
	- Tests reading comprehension and critical thinking
	- Includes detailed explanations for correct answers
	- Uses vocabulary appropriate for "#{grade_level}" grade level

	For each question, provide:
	1. The question text
	2. Four possible answers (with one correct answer)
	3. An explanation of the correct answer

	Do not number the questions.
PROMPT

  tool_name = "send_to_manager"
  tool_choice = { "type" => "tool", "name" => tool_name }

  payload = {
    model: @model,
    messages: [{ role: "user", content: prompt }],
    max_tokens: 8192,
    system: "You are a helpful AI assistant that generates educational content.",
    tools: [
      {
        "name" => tool_name,
        "description" => "Send structured reading assignment to a manager",
        "input_schema" => tool_input_schema
      }
    ],
    tool_choice: tool_choice
  }

  Rails.logger.info "[Anthropic Provider] Test request payload: #{payload.inspect}"

  begin
    response = make_request(payload)
    Rails.logger.info "[Anthropic Provider] Response status: #{response.status}"
    Rails.logger.info "[Anthropic Provider] Raw response: #{response.body}"

    if response.success?
      # Extract tool block if present
      tool_blocks = response.body["content"].select { |block| block["type"] == "tool" }
      if tool_blocks && !tool_blocks.empty?
        Rails.logger.info "[Anthropic Provider] Test successful!"
        return tool_blocks.first["input"]
      else
        Rails.logger.warn "[Anthropic Provider] No tool block returned!"
        return response.body
      end
    else
      Rails.logger.error "[Anthropic Provider] Test failed with status #{response.status}"
      Rails.logger.error "[Anthropic Provider] Error response: #{response.body}"
      false
    end
  rescue StandardError => e
    Rails.logger.error "[Anthropic Provider] Test failed!"
    Rails.logger.error "[Anthropic Provider] Error class: #{e.class}"
    Rails.logger.error "[Anthropic Provider] Error message: #{e.message}"
    false
        end
      end

      def chat(messages:, system_prompt: nil, max_tokens: 8192, response_format: nil)
        Rails.logger.info "[Anthropic Provider] Starting chat request with model: #{@model}"
        
        normalized_messages = messages.is_a?(Array) ? messages : [{ role: "user", content: messages }]
        tool_name = "send_to_manager"
        tool_choice = { "type" => "tool", "name" => tool_name }
        
        payload = {
          model: @model,
          max_tokens: max_tokens,
          messages: normalized_messages,
          system: system_prompt,
          tools: [
            {
              "name" => tool_name,
              "description" => "Send structured reading assignment to a manager",
              "input_schema" => tool_input_schema
            }
          ],
          tool_choice: tool_choice
        }
        
        Rails.logger.info "[Anthropic Provider] Request payload: #{payload.inspect}"
        
        begin
          response = make_request(payload)
          Rails.logger.info "[Anthropic Provider] Response status: #{response.status}"
          Rails.logger.info "[Anthropic Provider] Raw response: #{response.body}"
          
          # Extract tool_use content
          tool_blocks = response.body.dig("content")&.find { |block| block["type"] == "tool_use" }
          
          if tool_blocks && tool_blocks["input"]
            Rails.logger.info "[Anthropic Provider] Successfully extracted tool input"
            tool_blocks["input"].to_json
          else
            Rails.logger.warn "[Anthropic Provider] No tool input found in response"
            Rails.logger.warn "[Anthropic Provider] Content blocks: #{response.body["content"]&.map { |b| b["type"] }}"
            raise "No tool input found in response"
          end
        rescue StandardError => e
          Rails.logger.error "[Anthropic Provider] Request failed!"
          Rails.logger.error "[Anthropic Provider] Error class: #{e.class}"
          Rails.logger.error "[Anthropic Provider] Error message: #{e.message}"
          raise "Anthropic API Error: #{e.message}"
        end
      end

      private

      def make_request(payload)
        @conn.post do |req|
          req.headers['anthropic-version'] = ANTHROPIC_API_VERSION
          req.headers['x-api-key'] = @api_key
          req.headers['content-type'] = 'application/json'
          req.body = payload.to_json
        end
      end

      def generate_image(prompt:, size: "1024x1024", quality: "standard", n: 1)
        raise NotImplementedError, "Anthropic does not support image generation"
      end
    end
  end
end