FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { 'password123' }
    
    trait :teacher do
      role { 'teacher' }
    end
    
    trait :student do
      role { 'student' }
    end
  end
end 