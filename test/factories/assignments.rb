FactoryBot.define do
  factory :assignment do
    sequence(:title) { |n| "Assignment #{n}" }
    subject { "Mathematics" }
    grade_level { 5 }
    difficulty { "Medium" }
    number_of_questions { 10 }
    interests { "algebra, geometry, and problem-solving" }
    published { false }
    
    trait :with_creator do
      transient do
        user { nil }
      end
      
      after(:create) do |assignment, evaluator|
        if evaluator.user
          create(:assignment_user, assignment: assignment, user: evaluator.user, role: 'creator')
        end
      end
    end

    trait :published do
      published { true }
    end
  end
end 