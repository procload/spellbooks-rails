FactoryBot.define do
  factory :student_answer do
    association :question
    association :assignment_user
    answer { "Sample Answer" }
    correct { false }
  end
end
