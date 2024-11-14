class ProcessAssignmentJob < ApplicationJob
  queue_as :default

  retry_on Faraday::UnauthorizedError, wait: 5.seconds, attempts: 3
  retry_on ActiveRecord::RecordNotFound, wait: 5.seconds, attempts: 3

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    
    return unless assignment # Skip if assignment not found
    
    client = OpenAI::Client.new(
      access_token: ENV.fetch('OPENAI_API_KEY'),
      request_timeout: 240
    )
    
    Sidekiq.logger.info "=== Starting ProcessAssignmentJob for assignment_id: #{assignment_id} ==="
    
    begin
      Sidekiq.logger.info "Found assignment: #{assignment.title}"
      
      # Skip image generation in development unless explicitly enabled
      unless Rails.env.development? && ENV['SKIP_IMAGE_GENERATION'] == 'true'
        # Generate image with DALL-E 3
        image_prompt = generate_image_prompt(assignment)
        Sidekiq.logger.info "Generated image prompt: #{image_prompt}"
        
        image_response = client.images.generate(
          parameters: {
            model: "dall-e-3",
            prompt: image_prompt,
            size: "1024x1024",
            quality: "standard",
            n: 1
          }
        )
        
        # Save the image URL from DALL-E
        image_url = image_response.dig("data", 0, "url")
        if image_url
          # Instead of just saving the URL, download and attach the image
          if assignment.attach_image_from_url(image_url)
            Sidekiq.logger.info "Successfully attached image for assignment #{assignment_id}"
          else
            Sidekiq.logger.error "Failed to attach image for assignment #{assignment_id}"
          end
        end
      end
      
      prompt = PromptGeneratorService.generate_prompt(assignment)
      Sidekiq.logger.info "Generated prompt with length: #{prompt.length}"
      
      Rails.logger.info "Making OpenAI API request..."
      response = client.chat(
        parameters: {
          model: "gpt-4o-2024-08-06",
          messages: [
            { 
              role: "system", 
              content: "You are a helpful AI assistant that generates educational content. Generate a passage and multiple choice questions based on the given parameters. The response must strictly follow the JSON schema provided."
            },
            { role: "user", content: prompt }
          ],
          response_format: {
            type: "json_schema",
            json_schema: {
              "strict": true,
              "name": "Assignment",
              "description": "Generates an educational assignment",
              "schema": ::ASSIGNMENT_SCHEMA,
            }	
          }	
        }
      )
      Sidekiq.logger.info "Received response from OpenAI"
      
      content = response.dig("choices", 0, "message", "content")
      Sidekiq.logger.info "Raw content type: #{content.class}"
      content = JSON.parse(content) if content.is_a?(String)
      Sidekiq.logger.info "Parsed content successfully"
      
      ActiveRecord::Base.transaction do
        Sidekiq.logger.info "Starting database transaction"
        
        # Update assignment with the passage
        assignment.update!(passage: content["passage"])
        Sidekiq.logger.info "Updated assignment passage"
        
        # Save questions and their answers
        content["questions"].each_with_index do |q, index|
          Sidekiq.logger.info "Creating question #{index + 1} of #{content["questions"].length}"
          
          # Build the question with answers nested
          question_attributes = {
            content: q["question_text"],
            explanation: q["explanation"],
            answers_attributes: q["answers"].map do |answer|
              {
                text: answer["text"],
                is_correct: answer["is_correct"]
              }
            end
          }

          # Create question with nested answers in one go
          question = assignment.questions.create!(question_attributes)
          Sidekiq.logger.info "Created question #{index + 1} with #{question.answers.count} answers"
        end
        
        # Generate markdown version of the passage
        GenerateMarkdownJob.perform_later(assignment.id) if assignment.passage.present?

        # Update assignment status
        assignment.update!(status: 'completed')

        # Replace the existing broadcast with:
        Turbo::StreamsChannel.broadcast_append_to(
          "assignments",
          target: "toasts",
          partial: "shared/toast",
          locals: {
            type: "success",
            message: "Assignment '#{assignment.title}' is ready!",
            link_path: Rails.application.routes.url_helpers.assignment_path(assignment),
            link_text: "View Assignment"
          }
        )
      end
    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      raise # Re-raise to trigger retry
    rescue StandardError => e
      Rails.logger.error "ProcessAssignmentJob Error: #{e.message}"
      raise
    ensure
      Sidekiq.logger.info "=== Finished ProcessAssignmentJob for assignment_id: #{assignment_id} ==="
    end
  end

  private

  def generate_image_prompt(assignment)
    base_prompt = case assignment.subject
    when "Math"
      "Create an educational, kid-friendly illustration about #{assignment.subject} that incorporates"
    when "Art"
      "Create a vibrant, inspiring artwork that combines #{assignment.subject} with"
    when "History"
      "Create a historically accurate but kid-friendly illustration about #{assignment.subject} that includes"
    when "Reading Comprehension"
      "Create an engaging book-themed illustration that features"
    when "Physics"
      "Create a scientific but fun illustration demonstrating physics concepts with"
    end

    interests = assignment.interests.presence || "general educational themes"
    grade_level_term = if assignment.grade_level <= 5
      "young students"
    elsif assignment.grade_level <= 8
      "middle school students"
    else
      "high school students"
    end

    "#{base_prompt} #{interests}. The style should be appropriate for #{grade_level_term}, " \
    "using bright colors and clear shapes. Make it educational but engaging, avoiding any " \
    "text or numbers in the image. The style should be modern and slightly cartoonish while " \
    "maintaining educational value."
  end

  def track_dalle_usage
    Rails.logger.info "DALL-E API call cost: $0.04"
    # Add to a counter or monitoring service
  end
end 