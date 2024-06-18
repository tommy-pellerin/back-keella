FactoryBot.define do
  factory :reservation do
    association :user, factory: :user
    association :workout, factory: :workout
    quantity { 5 }
    total { quantity * workout.price }
  end
end
