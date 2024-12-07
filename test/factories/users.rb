FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "student" }

    trait :teacher do
      role { "teacher" }
      teacher { nil }
    end

    trait :student do
      role { "student" }
      association :teacher, factory: :user, role: 'teacher'
    end
  end
end 