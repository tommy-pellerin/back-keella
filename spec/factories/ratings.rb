FactoryBot.define do
  factory :rating do
    rating { 1 }
    comment { "MyText" }
    is_workout_rating { false }
    association :workout
    association :user
    association :rated_user, factory: :user
  end
end
