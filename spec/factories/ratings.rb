FactoryBot.define do
  factory :rating do
    rating { rand(1..5) }
    comment { "MyText" }
    association :user, factory: :user
    association :rateable, factory: :workout
    association :workout, factory: :workout
  end
end
