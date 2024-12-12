class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :assignment_user, optional: true
  
  validates :text, presence: true
end
