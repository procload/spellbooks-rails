class AssignmentUser < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  
  ROLES = %w[creator student].freeze
  STATUSES = %w[pending in_progress completed].freeze
  
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: [:assignment_id, :role] }
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  
  scope :creators, -> { where(role: 'creator') }
  scope :students, -> { where(role: 'student') }
  
  has_many :student_answers, dependent: :destroy
  
  before_create :set_default_status

  private

  def set_default_status
    self.status = 'pending' if role == 'student' && status.nil?
  end
end 