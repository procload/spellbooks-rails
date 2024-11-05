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
        
        Rails.logger.info "Prompt sent to OpenAI: #{prompt}"
        Rails.logger.info "Full OpenAI Response: #{response.inspect}"
        
        redirect_to assignments_path, notice: 'Assignment was successfully created.'
      rescue => e
        Rails.logger.error "OpenAI API Error: #{e.message}"
        Rails.logger.error "Full error details: #{e.inspect}"
        redirect_to assignments_path, alert: 'Error generating questions. Please try again.'
      end
    else
      render :new
    end
  end

  private

	

  def generate_prompt(assignment)
    """
    Create an educational assignment with the following parameters:
    Title: #{assignment.title}
    Subject: #{assignment.subject}
    Grade Level: #{assignment.grade_level}
    Difficulty: #{assignment.difficulty}
    Number of Questions: #{assignment.number_of_questions}
    Student Interests: #{assignment.interests}
    """
  end

  def assignment_params
    params.require(:assignment).permit(:title, :subject, :grade_level, :difficulty, :number_of_questions, :interests)
  end
end