class AssignmentSubmissionsController < ApplicationController
  # Use assignment layout for all actions
  layout 'assignment'
  before_action :require_student
  before_action :set_assignment

  def create
    @assignment_user = @assignment.assignment_users.find_by(user: Current.user)
    
    if @assignment_user.update(submission_params)
      redirect_to @assignment, notice: 'Assignment status updated successfully.'
    else
      redirect_to @assignment, alert: 'Error updating assignment status.'
    end
  end

  private

  def set_assignment
    @assignment = Assignment.joins(:assignment_users)
                          .where(assignment_users: { user: Current.user, role: 'student' })
                          .find(params[:assignment_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Assignment not found or not assigned to you"
  end

  def submission_params
    params.permit(:status)
  end
end 