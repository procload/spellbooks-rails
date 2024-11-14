class Answer < ApplicationRecord
  belongs_to :question
  validates :text, presence: true, length: { minimum: 1, maximum: 1000 }
end
