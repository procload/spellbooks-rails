class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :assignment_user, optional: true
  
  validates :content, presence: true
  
  after_save :update_assignment_user_status, if: :assignment_user_id?
  
  private
  
  def update_assignment_user_status
    total_questions = assignment_user.assignment.questions.count
    answered_questions = assignment_user.answers.count
    
    if answered_questions == 0
      assignment_user.update(status: 'pending')
    elsif answered_questions < total_questions
      assignment_user.update(status: 'in_progress')
    else
      assignment_user.update(status: 'completed')
    end
  end
end
