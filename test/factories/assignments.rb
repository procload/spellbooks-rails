FactoryBot.define do
  factory :assignment do
    sequence(:title) { |n| "Assignment #{n}" }
    subject { "Math" }
    grade_level { "5" }
    difficulty { "Medium" }
    number_of_questions { 10 }
    interests { "test interests" }

    trait :with_creator do
      after(:create) do |assignment, evaluator|
        create(:assignment_user, 
          assignment: assignment, 
          user: evaluator.user || create(:user, :teacher),
          role: 'creator'
        )
      end
    end
  end
end 