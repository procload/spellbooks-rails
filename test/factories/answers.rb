FactoryBot.define do
  factory :answer do
    association :question
    text { "Sample answer" }
    is_correct { false }
    
    trait :correct do
      is_correct { true }
    end
    
    trait :incorrect do
      is_correct { false }
    end
  end
end
