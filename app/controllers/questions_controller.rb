class QuestionsController < ApplicationController
  include ActionView::RecordIdentifier
  include ErrorHandling
  before_action :set_assignment
  before_action :set_question, only: [:show, :edit, :update, :check_answer, :regenerate]
  
  def index
    @questions = @assignment.questions
  end

  def show
    @question = @assignment.questions.find(params[:id])
  end

  def check_answer
    Rails.logger.info "Checking answer for Question #{@question.id} in Assignment #{@assignment.id}"
    Rails.logger.info "Params received: #{params.inspect}"
    
    selected_answer = params[:answer]
    is_correct = @question.correct_answer?(selected_answer)
    
    Rails.logger.info "Selected answer: #{selected_answer}"
    Rails.logger.info "Answer is correct: #{is_correct}"

    # Find the assignment user record
    assignment_user = @assignment.assignment_users.find_by(
      user: Current.user,
      role: 'student'
    )

    unless assignment_user
      Rails.logger.error "No assignment_user found for user #{Current.user.id} and assignment #{@assignment.id}"
      return head :unprocessable_entity
    end

    # Create or update the student answer
    @student_answer = StudentAnswer.find_or_initialize_by(
      assignment_user: assignment_user,
      question: @question
    )

    @student_answer.answer = selected_answer
    @student_answer.correct = is_correct
    @student_answer.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to assignment_path(@assignment) }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    Rails.logger.info "Starting question update for Question #{@question.id}"
    
    ActiveRecord::Base.transaction do
      if params[:correct_answer].present?
        answer_id = params[:correct_answer]
        
        # Update all answers atomically
        @question.answers.each do |answer|
          answer.update!(is_correct: (answer.id.to_s == answer_id.to_s))
        end
      end

      if @question.update(question_params)
        respond_to do |format|
          format.html { redirect_to @assignment, notice: 'Question was successfully updated.' }
          format.json { render json: { success: true, html: render_to_string(partial: 'question', locals: { question: @question }) } }
          format.turbo_stream { 
            render turbo_stream: turbo_stream.replace(
              @question,
              partial: "questions/question",
              locals: { question: @question, question_counter: params[:question_counter].to_i }
            )
          }
        end
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_validation_error(@question, e)
  rescue StandardError => e
    handle_turbo_stream_error(@question, e, params[:question_counter].to_i)
  end

  def destroy
    @question.destroy
    redirect_to @assignment, notice: 'Question was successfully deleted.'
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
      handle_turbo_stream_error(@question, e, params[:question_counter].to_i)
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
    # Log the raw params before permitting
    Rails.logger.info "Raw params for question_params: #{params[:question]}"
    
    permitted = params.require(:question).permit(
      :content, 
      :explanation,
      answers_attributes: [:id, :text, :is_correct]
    )
    
    Rails.logger.info "Permitted params: #{permitted.inspect}"
    permitted
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

  def handle_save_error
    respond_to do |format|
      format.html { 
        redirect_to assignment_path(@assignment), 
        alert: "Failed to save your answer. Please try again." 
      }
      format.json { 
        render json: { 
          error: "Failed to save answer",
          messages: @student_response.errors.full_messages 
        }, status: :unprocessable_entity 
      }
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          dom_id(@question, :feedback),
          html: "<div class='text-red-600'>Failed to save your answer. Please try again.</div>"
        )
      }
    end
  end
end 