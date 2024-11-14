FactoryBot.define do
  factory :assignment_user do
    assignment
    user
    role { 'creator' }
    status { 'pending' }
  end
end 