class QuestionPromptService
  def self.system_prompt
    "You are an expert teacher and question generator. Your task is to create high-quality, 
    engaging multiple-choice questions based on the given subject and interests. Each question should:

    1. Be clear and unambiguous
    2. Have exactly one correct answer
    3. Include plausible but incorrect distractors
    4. Match the specified difficulty level
    5. Incorporate student interests where relevant
    6. Include a detailed explanation of the correct answer

    Your response must be a valid JSON object with this exact structure:
    {
      \"passage\": \"A reading passage about the topic\",
      \"questions\": [
        {
          \"question_text\": \"The question to ask\",
          \"answers\": [
            { \"text\": \"First option\", \"is_correct\": false },
            { \"text\": \"Second option\", \"is_correct\": false },
            { \"text\": \"Correct option\", \"is_correct\": true },
            { \"text\": \"Fourth option\", \"is_correct\": false }
          ],
          \"explanation\": \"Why the correct answer is correct\"
        }
      ]
    }"
  end

  def self.generate_prompt(assignment)
    <<~PROMPT
      Generate #{assignment.number_of_questions} multiple choice questions about #{assignment.interests}.
      Subject: #{assignment.subject || 'General Knowledge'}
      Difficulty: #{assignment.difficulty || 'Medium'}
      Student Interests: #{assignment.interests}

      For each question, provide:
      1. The question text
      2. A detailed explanation
      3. Four answer choices, with exactly one correct answer
      4. Mark which answer is correct
    PROMPT
  end
end
