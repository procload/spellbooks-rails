class ProcessAssignmentJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    Sidekiq.logger.info "=== Starting ProcessAssignmentJob for assignment_id: #{assignment_id} ==="
    
    begin
      assignment = Assignment.find(assignment_id)
      Sidekiq.logger.info "Found assignment: #{assignment.title}"
      
      client = OpenAI::Client.new
      Sidekiq.logger.info "Created OpenAI client"
      
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
          question = assignment.questions.create!(
            content: q["question_text"],
            explanation: q["explanation"]
          )
          
          q["answers"].each_with_index do |answer, ans_index|
            Sidekiq.logger.info "Creating answer #{ans_index + 1} for question #{index + 1}"
            question.answers.create!(
              text: answer["text"],
              is_correct: answer["is_correct"]
            )
          end
        end
        Sidekiq.logger.info "Finished creating questions and answers"

        # Instead of Turbo broadcast, update assignment status
        assignment.update!(status: 'completed')
      end
    rescue StandardError => e
      Sidekiq.logger.error "!!! Error in ProcessAssignmentJob !!!"
      Sidekiq.logger.error e.message
      Sidekiq.logger.error e.backtrace.join("\n")
      
      # Update assignment status instead of Turbo broadcast
      assignment&.update(status: 'failed')
      
      # Clean up the failed assignment
      assignment&.destroy
      raise e # Re-raise the error for Sidekiq to handle
    ensure
      Sidekiq.logger.info "=== Finished ProcessAssignmentJob for assignment_id: #{assignment_id} ==="
    end
  end
end 