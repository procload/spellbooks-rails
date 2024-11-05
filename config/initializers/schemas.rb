QUESTION_SCHEMA = {
	type: "object",
	required: ["question_text", "answers", "explanation"],
	properties: {
		question_text: {
			type: "string",
			description: "The text of the question"
		},
		answers: {
			type: "array",
			items: {
				type: "object",
				required: ["text", "is_correct"],
				properties: {
					text: {
						type: "string",
						description: "The text of the answer option"
					},
					is_correct: {
						type: "boolean",
						description: "Whether this is the correct answer"
					}
				},
				"additionalProperties": false 
			},
		},
		explanation: {
			type: "string",
			description: "Explanation of why the correct answer is correct"
		}
	},
	"additionalProperties": false 
}
