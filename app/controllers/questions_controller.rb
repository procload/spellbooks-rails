class QuestionsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_assignment
  before_action :set_question, only: [:show, :edit, :update, :check_answer, :regenerate]

  def index
    @questions = @assignment.questions
  end

  def show
    @question = @assignment.questions.find(params[:id])
  end

  def check_answer
    @question = @assignment.questions.find(params[:id])
    selected_answer = params[:answer]
    
    is_correct = @question.correct_answer?(selected_answer)
    
    render json: {
      correct: is_correct,
      explanation: @question.explanation
    }
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    if @question.update(question_params)
      # Update answers
      params[:answers]&.each do |answer_id, answer_data|
        answer = @question.answers.find(answer_id)
        answer.update(
          text: answer_data[:text],
          is_correct: answer_data[:is_correct] == "1"
        )
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @assignment, notice: 'Question was successfully updated.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit }
        format.html { render :edit }
      end
    end
  end

  def regenerate
    client = OpenAI::Client.new
    prompt = generate_single_question_prompt(@question)
    
    Rails.logger.info "Regenerating question #{@question.id} for assignment #{@assignment.id}"
    Rails.logger.info "Generated prompt: #{prompt}"
    
    begin
      Rails.logger.info "Making OpenAI API request..."
      response = client.chat(
        parameters: {
          model: "gpt-4o-2024-08-06",
          messages: [
            { 
              role: "system", 
              content: "You are a helpful AI assistant that generates educational content. Generate a single multiple choice question based on the given parameters and passage. The response must strictly follow the JSON schema provided."
            },
            { role: "user", content: prompt }
          ],
          response_format: {
            type: "json_schema",
            json_schema: {
              "strict": true,
              "name": "Assignment",
              "description": "Generates a question for an educational assignment",
              "schema": QUESTION_SCHEMA,
            }	
          }	
        }
      )
      
      Rails.logger.info "OpenAI API Response received: #{response.inspect}"
      
      content = JSON.parse(response.dig("choices", 0, "message", "content"))
      Rails.logger.info "Parsed content: #{content.inspect}"
      
      ActiveRecord::Base.transaction do
        Rails.logger.info "Updating question #{@question.id} with new content"
        
        # Update the question
        @question.update!(
          content: content["question_text"],
          explanation: content["explanation"]
        )
        
        # Delete old answers and create new ones
        Rails.logger.info "Deleting old answers and creating #{content["answers"].length} new answers"
        @question.answers.destroy_all
        content["answers"].each do |answer|
          @question.answers.create!(
            text: answer["text"],
            is_correct: answer["is_correct"]
          )
        end
        
        Rails.logger.info "Successfully updated question and answers"
        respond_to do |format|
          format.turbo_stream
        end
      end
    rescue StandardError => e
      Rails.logger.error "Error regenerating question: #{e.message}"
      Rails.logger.error "Full error details: #{e.inspect}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      
      render turbo_stream: turbo_stream.replace(dom_id(@question), 
        partial: "question", 
        locals: { question: @question, question_counter: params[:question_counter].to_i }
      ), status: :unprocessable_entity
    end
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id])
  end

  def set_question
    @question = @assignment.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:content, :explanation)
  end

  def generate_single_question_prompt(question)
    assignment = question.assignment
    """
    Generate a single multiple choice question for the following assignment:
    
    Title: #{assignment.title}
    Subject: #{assignment.subject}
    Grade Level: #{assignment.grade_level}
    Difficulty: #{assignment.difficulty}
    
    #{assignment.passage.present? ? "Based on this passage:\n\n#{assignment.passage}\n\n" : ""}
    
    Generate:
    1. A question that tests comprehension and critical thinking
    2. Four possible answers (with exactly one correct answer)
    3. A detailed explanation for the correct answer
    
    The question should be appropriate for grade #{assignment.grade_level} students 
    and match the #{assignment.difficulty} difficulty level.
    """
  end
end 