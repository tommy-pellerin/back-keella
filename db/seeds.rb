# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

User.destroy_all
Reservation.destroy_all
Workout.destroy_all

User.create(
  username: 'admin',
  email: 'admin@admin.fr',
  password: 'admin123',
)
puts 'Admin created'

20.times do
  User.create(
    username: Faker::Name.first_name,
    email: Faker::Internet.email,
    password: 'password',
  )
end
puts 'Users created'

25.times do
  Workout.create(
    title: Faker::Lorem.sentence,
    description: Faker::Lorem.paragraph,
    start_date: Faker::Time.forward(days: 23, period: :morning),
    duration: rand(1..3)*30,
    city: Faker::Address.city,
    zip_code: Faker::Address.zip_code,
    price: rand(1..50),
    max_participants: rand(1..10),
    host: User.all.sample
  )
end
puts 'Workouts created'

50.times do
  user = User.all.sample
  workout = Workout.all.sample
  while user == workout.host
    workout = Workout.all.sample
  end
  Reservation.create(
    user: User.all.sample,
    workout: Workout.all.sample,
    quantity: rand(1..10),
    total: rand(1.0..50.0),
    status: rand(0..2)
  )
end
puts 'Reservations created'
