ASSIGNMENT_SCHEMA = {
		type: 'object',
		properties: {
			passage: { type: 'string' },
			questions: {
				type: 'array',
				items: {
					type: 'object',
					properties: {
						question_text: { type: 'string' },
						answers: {
							type: 'array',
							items: {
								type: 'object',
								properties: {
									text: { type: 'string' },
									is_correct: { type: 'boolean' }
								},
								required: %w[text is_correct],
								"additionalProperties": false
							},
						},
						explanation: { type: 'string' }
					},
					required: %w[question_text answers explanation],
					"additionalProperties": false
				}
			}
		},
		required: %w[passage questions],
		"additionalProperties": false
	}.freeze 
