module LLM
  class ResponseValidator
    def self.validate_and_transform(response)
      # First, validate the response has the required structure
      unless response.is_a?(Hash) && response[:passage].is_a?(String) && response[:questions].is_a?(Array)
        raise LLM::Error, "Invalid response structure: missing required fields"
      end

      # Transform questions to match our schema
      questions = response[:questions].map do |q|
        unless q[:question_text].is_a?(String) && q[:answers].is_a?(Array) && q[:explanation].is_a?(String)
          raise LLM::Error, "Invalid question structure: missing required fields"
        end

        # Validate answers
        unless q[:answers].length == 4 && q[:answers].one? { |a| a[:is_correct] }
          raise LLM::Error, "Invalid answers: must have exactly 4 answers with one correct"
        end

        {
          question_text: q[:question_text],
          answers: q[:answers].map { |a| { text: a[:text], is_correct: a[:is_correct] } },
          explanation: q[:explanation]
        }
      end

      { passage: response[:passage], questions: questions }
    end
  end
end
