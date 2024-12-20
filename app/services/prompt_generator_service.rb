class PromptGeneratorService
  def self.generate_prompt(assignment)
    Rails.logger.info "Generating prompt for subject: #{assignment.subject}"
    
    prompt_filename = PromptMapperService.get_prompt_filename(assignment.subject)
    Rails.logger.info "Mapped to prompt file: #{prompt_filename}"
    
    template_path = Rails.root.join('lib', 'prompts', prompt_filename)
    Rails.logger.info "Looking for template at: #{template_path}"
    
    if File.exist?(template_path)
      template = File.read(template_path)
      Rails.logger.info "Found template, length: #{template.length} characters"
      
      # Create a binding where 'assignment' is available
      b = binding
      b.local_variable_set(:assignment, assignment)
      
      prompt = ERB.new(template).result(b)
      Rails.logger.info "Generated prompt, length: #{prompt.length} characters"
      Rails.logger.debug "Full prompt content: #{prompt}"
      prompt
    else
      Rails.logger.warn "No prompt template found for subject: #{assignment.subject}"
      fallback = """
        Create an educational assignment with the following parameters:
        Title: #{assignment.title}
        Subject: #{assignment.subject}
        Grade Level: #{assignment.grade_level}
        Difficulty: #{assignment.difficulty}
        Number of Questions: #{assignment.number_of_questions}
        Student Interests: #{assignment.interests}
      """
      Rails.logger.info "Using fallback prompt"
      Rails.logger.debug "Fallback prompt content: #{fallback}"
      fallback
    end
  end
end 