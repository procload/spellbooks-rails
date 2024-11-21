class AnswersController < ApplicationController
  before_action :set_question
  before_action :require_teacher
  
  def new
    @answer = @question.answers.build
  end

  def create
    @answer = @question.answers.build(answer_params)
    
    if @answer.save
      redirect_to assignment_path(@assignment), notice: 'Answer was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @answer = @question.answers.find(params[:id])
    @answer.destroy
    
    redirect_to assignment_path(@assignment), notice: 'Answer was successfully removed.'
  end

  private

  def set_question
    @assignment = Assignment.find(params[:assignment_id])
    @question = @assignment.questions.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:text, :is_correct)
  end
end 