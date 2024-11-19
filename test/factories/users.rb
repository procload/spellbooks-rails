FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "student" }

    trait :teacher do
      role { "teacher" }
    end

    trait :student do
      role { "student" }
    end
  end
end 