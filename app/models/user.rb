class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :assignment_users, dependent: :destroy
  has_many :assignments, through: :assignment_users

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  
  # Define valid roles
  ROLES = %w[teacher student].freeze
  
  # Validations
  validates :role, inclusion: { in: ROLES }, allow_nil: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email_address, presence: true, 
                          uniqueness: true,
                          format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # Role checking methods
  def teacher?
    role == 'teacher'
  end
  
  def student?
    role == 'student'
  end
  
  # Scopes for easily finding teachers and students
  scope :teachers, -> { where(role: 'teacher') }
  scope :students, -> { where(role: 'student') }
  
  # Get assignments specific to role
  def relevant_assignments
    if teacher?
      assignments.joins(:assignment_users)
                .where(assignment_users: { role: 'creator' })
                .distinct
    else
      assignments.joins(:assignment_users)
                .where(assignment_users: { role: 'student' })
                .distinct
    end
  end
end
