module LLM
  QUESTION_SCHEMA = {
    type: "object",
    properties: {
      passage: {
        type: "string",
        description: "The reading passage for the assignment"
      },
      questions: {
        type: "array",
        items: {
          type: "object",
          properties: {
            question: {
              type: "string",
              description: "The question text"
            },
            explanation: {
              type: "string",
              description: "A detailed explanation of the correct answer"
            },
            choices: {
              type: "array",
              items: {
                type: "string"
              },
              minItems: 4,
              maxItems: 4,
              description: "Four possible answers"
            },
            correct: {
              type: "string",
              description: "The correct answer, must match one of the choices exactly"
            }
          },
          required: ["question", "explanation", "choices", "correct"],
          additionalProperties: false
        },
        minItems: 1
      }
    },
    required: ["passage", "questions"],
    additionalProperties: false
  }
end
