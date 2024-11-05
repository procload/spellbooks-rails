require 'ostruct'

class AssignmentsController < ApplicationController

  def index
    @assignments = Assignment.all
  end

  def show
    @assignment = Assignment.find(params[:id])
    @questions = @assignment.questions
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)
    
    if @assignment.save
      client = OpenAI::Client.new
      prompt = generate_prompt(@assignment)
      
      begin
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
                "schema": ASSIGNMENT_SCHEMA,
              }	
            }	
          }
        )
        
        content = response.dig("choices", 0, "message", "content")
        content = JSON.parse(content) if content.is_a?(String)
        
        ActiveRecord::Base.transaction do
          # Update assignment with the passage
          @assignment.update!(passage: content["passage"])
          
          # Save questions and their answers
          content["questions"].each do |q|
            question = @assignment.questions.create!(
              content: q["question_text"],
              explanation: q["explanation"]
            )
            
            # Create answers for this question
            q["answers"].each do |answer|
              question.answers.create!(
                text: answer["text"],
                is_correct: answer["is_correct"]
              )
            end
          end
          
          redirect_to assignment_path(@assignment), notice: 'Assignment was successfully created.'
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Database validation error: #{e.message}"
        @assignment.destroy
        redirect_to assignments_path, alert: 'Error saving questions and answers. Please try again.'
      rescue StandardError => e
        Rails.logger.error "Error processing OpenAI response: #{e.message}"
        Rails.logger.error "Full error details: #{e.inspect}"
        @assignment.destroy
        redirect_to assignments_path, alert: 'Error generating questions. Please try again.'
      end
    else
      render :new
    end
  end

  private

	

  def generate_prompt(assignment)
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

  def assignment_params
    params.require(:assignment).permit(:title, :subject, :grade_level, :difficulty, :number_of_questions, :interests, :passage)
  end
end