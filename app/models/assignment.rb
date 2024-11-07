class Assignment < ApplicationRecord
  has_many :questions, dependent: :destroy
  
  validates :title, presence: true
  validates :subject, presence: true
  validates :grade_level, presence: true, inclusion: { in: 0..12 }
  validates :difficulty, presence: true
  validates :number_of_questions, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :interests, presence: true

  after_create_commit :process_assignment

  private

  def process_assignment
    ProcessAssignmentJob.perform_later(id)
  end
end
