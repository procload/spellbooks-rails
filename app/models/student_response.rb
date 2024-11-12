class StudentResponse < ApplicationRecord
  belongs_to :question
  belongs_to :user

  validates :answer_text, presence: true
  validates :user_id, uniqueness: { scope: :question_id, message: "has already answered this question" }

  after_save :update_assignment_progress
  
  private

  def update_assignment_progress
    return unless (assignment_user = question.assignment.assignment_users.find_by(user: user))
    
    progress = calculate_progress
    assignment_user.update(status: determine_status(progress))
  end

  def calculate_progress
    total = question.assignment.questions.count
    answered = StudentResponse.where(
      user_id: user.id,
      question_id: question.assignment.questions.pluck(:id)
    ).count
    
    [answered, total]
  end

  def determine_status(progress)
    answered, total = progress
    return 'completed' if answered == total
    return 'in_progress' if answered > 0
    'not_started'
  end
end 