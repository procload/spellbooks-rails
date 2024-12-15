module LLM
  class Service
    def self.generate_questions(assignment)
      new(assignment).generate_questions
    end

    def self.test_connection
      provider = LLMConfig.provider_class.new(LLMConfig.config[LLMConfig.provider.to_sym])
      provider.test_connection
    end

    def self.test_json_schema
      provider = LLMConfig.provider_class.new(LLMConfig.config[LLMConfig.provider.to_sym])
      provider.test_json_schema
    end

    def initialize(assignment)
      @assignment = assignment
      @provider = LLMConfig.provider_class.new(LLMConfig.config[LLMConfig.provider.to_sym])
    end

    def generate_questions
      prompt = build_prompt
      messages = [{ role: "user", content: prompt }]
      response = @provider.chat(messages: messages, system_prompt: system_prompt)
      
      # Validate and transform the response
      validated_response = ResponseValidator.validate_and_transform(response)
      
      # Store the passage in the assignment if present
      @assignment.update(passage: validated_response[:passage]) if validated_response[:passage].present?
      
      # Return the questions array
      validated_response[:questions]
    rescue StandardError => e
      raise LLM::Error, "Failed to generate questions: #{e.message}"
    end

    private

    def build_prompt
      <<~PROMPT
        Generate #{@assignment.number_of_questions} multiple choice questions about #{@assignment.title}.
        Subject: #{@assignment.subject}
        Difficulty: #{@assignment.difficulty}
        Student Interests: #{@assignment.interests}

        For each question, provide:
        1. The question text
        2. A detailed explanation
        3. Four answer choices, with exactly one correct answer
        4. Mark which answer is correct
      PROMPT
    end

    def system_prompt
      <<~PROMPT
        You are an expert teacher and question generator. Your task is to create high-quality, 
        engaging multiple-choice questions based on the given subject and topic. Each question should:
        
        1. Be clear and unambiguous
        2. Have exactly one correct answer
        3. Include plausible but incorrect distractors
        4. Match the specified difficulty level
        5. Incorporate student interests where relevant
        6. Include a detailed explanation of the correct answer
        
        Your response must be a valid JSON object with this exact structure:
        {
          "passage": "A reading passage about the topic",
          "questions": [
            {
              "question_text": "The question to ask",
              "answers": [
                { "text": "First option", "is_correct": false },
                { "text": "Second option", "is_correct": false },
                { "text": "Correct option", "is_correct": true },
                { "text": "Fourth option", "is_correct": false }
              ],
              "explanation": "Why the correct answer is correct"
            }
          ]
        }
      PROMPT
    end

    def parse_response(response)
      JSON.parse(response, symbolize_names: true)[:questions]
    rescue JSON::ParserError => e
      raise LLM::Error, "Failed to parse LLM response: #{e.message}"
    end
  end
end
