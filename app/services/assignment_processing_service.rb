class AssignmentProcessingService
  Result = Struct.new(:success?, :error, keyword_init: true)

  def initialize(assignment)
    @assignment = assignment
  end

  def execute
    ProcessAssignmentJob.perform_later(@assignment.id)
  end

  def regenerate_image
    generate_image
    success_result
  rescue => e
    Rails.logger.error "Error regenerating image: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    failure_result(e.message)
  end

  private

  def generate_questions
    ::LLM::Service.generate_questions(@assignment)
  end

  def create_questions(questions_data)
    questions_data.each do |question_data|
      @assignment.questions.create!(
        content: question_data[:question_text],
        explanation: question_data[:explanation],
        answers_attributes: question_data[:answers].map { |a| a.slice(:text, :is_correct) }
      )
    end
  end

  def generate_image
    image_prompt = ImagePromptService.generate_prompt(@assignment)
    Rails.logger.info "[AssignmentProcessingService] Image generation prompt: #{image_prompt}"
    
    provider = LLM::Factory.create_image_provider
    if image_url = provider.generate_image(prompt: image_prompt)
      @assignment.attach_image_from_url(image_url)
    end
  rescue => e
    Rails.logger.error "Error generating image: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def enqueue_markdown_job
    GenerateMarkdownJob.perform_later(@assignment.id)
  end

  def mark_as_completed
    @assignment.update!(status: 'completed')
  end

  def mark_as_pending
    @assignment.update!(status: 'pending') if @assignment.status == 'in_progress'
  end

  def success_result
    Result.new(success?: true, error: nil)
  end

  def failure_result(error)
    Result.new(success?: false, error: error)
  end
end
