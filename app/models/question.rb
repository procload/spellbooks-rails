class Question < ApplicationRecord
  belongs_to :assignment
  has_many :student_responses, dependent: :destroy
  has_many :answers, dependent: :destroy
  
  accepts_nested_attributes_for :answers, 
                              allow_destroy: true, 
                              reject_if: :all_blank

  validates :content, presence: true
  validates :explanation, presence: true
  
  def correct_answer?(answer_text)
    answers.exists?(text: answer_text, is_correct: true)
  end
  
  def correct_answer
    answers.find_by(is_correct: true)&.id&.to_s
  end
  
  def options
    answers.pluck(:text)
  end
end
