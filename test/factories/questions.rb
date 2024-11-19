FactoryBot.define do
  factory :question do
    association :assignment
    content { "What is 2 + 2?" }
    explanation { "The sum of 2 and 2 is 4" }
    
    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
