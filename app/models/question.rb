class Question < ApplicationRecord
  belongs_to :assignment
  has_many :student_responses, dependent: :destroy
  has_many :answers, dependent: :destroy
  
  accepts_nested_attributes_for :answers, 
                              allow_destroy: true, 
                              reject_if: :all_blank

  validates :content, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :explanation, presence: true, length: { minimum: 10, maximum: 2000 }
  
  validate :has_multiple_answers, unless: :skip_answer_validations
  validate :has_one_correct_answer, unless: :skip_answer_validations
  
  attr_accessor :skip_answer_validations
  
  def correct_answer?(answer_text)
    answers.exists?(text: answer_text, is_correct: true)
  end
  
  def correct_answer
    answers.find_by(is_correct: true)&.id&.to_s
  end
  
  def options
    answers.pluck(:text)
  end

  private

  def has_multiple_answers
    if answers.size < 2
      errors.add(:base, "Question must have at least two answers")
    end
  end

  def has_one_correct_answer
    correct_count = answers.count { |answer| answer.is_correct }
    if correct_count != 1
      errors.add(:base, "Question must have exactly one correct answer")
    end
  end
end
