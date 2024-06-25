FactoryBot.define do
  factory :user do
    username { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { 'password' }
    credit { 1000 }
    isAdmin { false }
  end
end
