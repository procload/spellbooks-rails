class ProcessAssignmentJob < ApplicationJob
  queue_as :default
  
  def perform(assignment_id)
    @assignment = Assignment.find(assignment_id)
    
    return unless @assignment.status == 'in_progress'
    
    begin
      ActiveRecord::Base.transaction do
        questions_data = generate_questions
        create_questions(questions_data)
        generate_image if @assignment.passage.present?
        enqueue_markdown_job if @assignment.passage.present?
        mark_as_completed
      end
      notify_success
    rescue StandardError => e
      mark_as_pending
      notify_failure(e)
      raise e
    end
  end
  
  private
  
  def generate_questions
    provider = LLM::Factory.create_provider
    prompt_filename = PromptMapperService.get_prompt_filename(@assignment.subject)
    prompt_path = Rails.root.join('lib', 'prompts', prompt_filename)
    
    system_prompt = File.read(prompt_path)
    generated_prompt = ERB.new(system_prompt).result_with_hash(
      assignment: @assignment
    )
    
    puts "\n================================================"
    puts "=== LLM Prompt for Assignment #{@assignment.id} ==="
    puts "=== Using Prompt Template: #{prompt_filename} ==="
    puts "=== System Prompt ==="
    puts system_prompt
    puts "=== Generated Prompt ==="
    puts generated_prompt
    puts "================================================\n"
    
    # Add number of questions constraint to the schema
    schema = ASSIGNMENT_SCHEMA.deep_dup
    
    provider.chat(
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
  end
  
  def create_questions(data)
    # Parse the data if it's a string
    data = JSON.parse(data, symbolize_names: true) if data.is_a?(String)
    
    @assignment.update!(passage: data[:passage]) if data[:passage].present?
    
    data[:questions].each do |q|
      Rails.logger.info "[ProcessAssignmentJob] Creating question with: content=#{q[:question_text]}, explanation=#{q[:explanation]}"
      
      # Create question with all required attributes
      question = @assignment.questions.new(
        content: q[:question_text],
        explanation: q[:explanation],
        skip_answer_validations: true
      )
      
      # Create all answers first
      q[:answers].each do |a|
        question.answers.build(
          text: a[:text],
          is_correct: a[:is_correct]
        )
      end
      
      question.save!
    end
  end
  
  def generate_image
    unless @assignment.passage.present?
      Rails.logger.info "[ProcessAssignmentJob] Skipping image generation - no passage present"
      return
    end
    
    Rails.logger.info "[ProcessAssignmentJob] Generating image for passage: #{@assignment.passage[0..100]}..."
    
    provider = LLM::Factory.create_image_provider
    url = provider.generate_image(
      prompt: ImagePromptService.generate_prompt(@assignment),
      size: "1024x1024",
      quality: "standard"
    )
    
    if url.present?
      Rails.logger.info "[ProcessAssignmentJob] Image generated successfully, URL: #{url}"
      if @assignment.attach_image_from_url(url)
        Rails.logger.info "[ProcessAssignmentJob] Image successfully attached to assignment"
      else
        Rails.logger.warn "[ProcessAssignmentJob] Failed to attach image to assignment"
      end
    else
      Rails.logger.warn "[ProcessAssignmentJob] No image URL returned from provider"
    end
  rescue StandardError => e
    Rails.logger.error "[ProcessAssignmentJob] Error generating image: #{e.class} - #{e.message}"
    Rails.logger.error "[ProcessAssignmentJob] #{e.backtrace.first(5).join("\n")}"
    raise
  end
  
  def enqueue_markdown_job
    GenerateMarkdownJob.perform_later(@assignment.id)
  end
  
  def mark_as_completed
    @assignment.update!(status: 'completed')
  end
  
  def mark_as_pending
    @assignment.update!(status: 'pending')
  end
  
  def notify_success
    teacher = @assignment.teachers.first
    if teacher
      ApplicationMailer.with(teacher: teacher, assignment: @assignment).assignment_ready_email.deliver_now
    else
      Rails.logger.warn "[ProcessAssignmentJob] No teacher found for assignment #{@assignment.id}, skipping email notification"
    end
  end
  
  def notify_failure(error)
    Rails.logger.error "[ProcessAssignmentJob] Failed to process assignment #{@assignment.id}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
  end
end