class AssignmentTestService
  def self.test_llm_generation(options = {})
    # Create a test assignment
    assignment = Assignment.new(
      title: options[:title] || "Test Assignment",
      subject: options[:subject] || "reading comprehension",
      grade_level: options[:grade_level]&.to_s || "6",
      difficulty: options[:difficulty] || "Medium",
      number_of_questions: options[:number_of_questions] || 5,
      interests: options[:interests] || "Science, Technology",
      status: "in_progress"
    )

    # Initialize the LLM provider
    provider = LLM::Factory.create_provider
    
    # Get the prompt
    prompt_filename = PromptMapperService.get_prompt_filename(assignment.subject)
    prompt_path = Rails.root.join('lib', 'prompts', prompt_filename)
    
    system_prompt = File.read(prompt_path)
    generated_prompt = ERB.new(system_prompt).result_with_hash(
      assignment: assignment
    )
    
    puts "\n=== Test Configuration ==="
    puts "Subject: #{assignment.subject}"
    puts "Grade Level: #{assignment.grade_level}"
    puts "Using prompt file: #{prompt_filename}"
    puts "\n=== System Prompt ==="
    puts system_prompt
    puts "\n=== Generated Prompt ==="
    puts generated_prompt
    puts "\n=== Making LLM Request ==="
    
    # Add number of questions constraint to the schema
    schema = ASSIGNMENT_SCHEMA.deep_dup

    
    # Make the LLM request
    response = provider.chat(
      messages: [generated_prompt],
      system_prompt: system_prompt,
      response_format: {
            type: "json_schema",
            json_schema: {
              "strict": true,
              "name": "Assignment",
              "description": "Generates an educational assignment",
              "schema": ::ASSIGNMENT_SCHEMA,
            }	
        }	
    )

    puts "\n=== LLM Response ==="
    pp response

    response
  end
end
