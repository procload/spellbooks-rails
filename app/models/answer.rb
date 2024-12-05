class Answer < ApplicationRecord
  belongs_to :question, touch: true
  has_many :student_responses, 
           ->(answer) { where(answer_text: answer.text) },
           class_name: 'StudentResponse',
           foreign_key: 'question_id',
           primary_key: 'question_id',
           dependent: :destroy
  
  validates :text, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :is_correct, inclusion: { in: [true, false] }
  
  after_save :touch_question
  
  private
  
  def touch_question
    question.touch if question.present?
  end
end
