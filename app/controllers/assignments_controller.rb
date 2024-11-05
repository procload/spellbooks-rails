class AssignmentsController < ApplicationController
  def index
    @assignments = Assignment.all
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      redirect_to assignments_path, notice: 'Assignment was successfully created.'
    else
      render :new
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit(:title, :subject, :grade_level, :difficulty, :number_of_questions, :interests)
  end
end