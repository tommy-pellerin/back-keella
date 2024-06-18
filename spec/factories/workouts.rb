FactoryBot.define do
  factory :workout do
    association :host, factory: :user
    association :category, factory: :category
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    price { 20 }
    max_participants { 10 }
    start_date { Faker::Time.forward(days: 3, period: :evening) }
    duration { 30 }
    city { Faker::Address.city }
    zip_code { Faker::Address.zip_code }
  end
end
