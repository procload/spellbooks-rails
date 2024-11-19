class Answer < ApplicationRecord
  belongs_to :question
  
  validates :text, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :is_correct, inclusion: { in: [true, false] }
  
  after_update :purge_assignment_pdf
  after_destroy :purge_assignment_pdf
  
  private
  
  def purge_assignment_pdf
    question.assignment.remove_cached_pdf if question&.assignment.present?
  end
end
