FactoryBot.define do
  factory :assignment_user do
    association :user
    association :assignment
    role { "student" }

    trait :creator do
      role { "creator" }
      association :user, :teacher
    end

    trait :student do
      role { "student" }
      association :user, :student
    end
  end
end 