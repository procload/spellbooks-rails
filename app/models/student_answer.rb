class StudentAnswer < ApplicationRecord
  belongs_to :assignment_user
  belongs_to :question
  
  validates :assignment_user_id, uniqueness: { scope: :question_id }
  validates :answer, presence: true
  
  after_save :update_assignment_user_status
  
  private
  
  def update_assignment_user_status
    total_questions = assignment_user.assignment.questions.count
    answered_questions = assignment_user.student_answers.count
    
    if answered_questions == 0
      assignment_user.update(status: 'pending')
    elsif answered_questions < total_questions
      assignment_user.update(status: 'in_progress')
    else
      assignment_user.update(status: 'completed')
    end
  end
end 