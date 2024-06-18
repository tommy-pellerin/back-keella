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
  isAdmin: true
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

categories = [ 'Yoga', 'Crossfit', 'Boxing', 'Course', 'Dance', 'Meditation', 'Pilates', 'Velos', 'Escalade', 'Gymnastique', 'Randonnees', 'Natation', 'Tennis', 'Football', 'Basketball', 'Volleyball', 'Handball', 'Rugby', 'Golf', 'Equitation' ]
categories.each do |category|
  Category.create(
    name: category
  )
end
puts 'Categories created'

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
    host: User.all.sample,
    category: Category.all.sample
  )
end
puts 'Workouts created'

50.times do
  user = User.all.sample
  quantity = rand(1..10)
  workout = Workout.all.sample
  while user == workout.host
    workout = Workout.all.sample
  end
  Reservation.create(
    user: user,
    workout: workout,
    quantity: quantity,
    total: workout.price * quantity,
    status: rand(0..2)
  )
end
puts 'Reservations created'
