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
Faker::Config.locale = 'fr'

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

ActionMailer::Base.perform_deliveries = false

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

100.times do
  user = User.all.sample
  workout = Workout.all.sample
  while user == workout.host
    workout = Workout.all.sample
  end
  Rating.create(
    user: user,
    workout: workout,
    rated_user: workout.host,
    rating: rand(1..5),
    is_workout_rating: true
  )
  end

ActionMailer::Base.perform_deliveries = true
puts 'Reservations created'

# Trouvez l'utilisateur admin
admin_user = User.find_by(isAdmin: true)

# Créez des séances d'entraînement hébergées par l'admin
5.times do
  Workout.create(
    title: Faker::Lorem.sentence,
    description: Faker::Lorem.paragraph,
    start_date: Faker::Time.forward(days: 23, period: :morning),
    duration: rand(1..3)*30,
    city: Faker::Address.city,
    zip_code: Faker::Address.zip_code,
    price: rand(1..50),
    max_participants: rand(1..10),
    host: admin_user,
    category: Category.all.sample
  )
end
puts 'Admin Workouts created'

# # Créez des réservations pour les séances d'entraînement de l'admin
Workout.where(host: admin_user).each do |workout|
  3.times do
    user = User.where.not(id: admin_user.id).sample
    Reservation.create(
      user: user,
      workout: workout,
      quantity: rand(1..3),
      total: workout.price * rand(1..3),
      status: ['pending', 'accepted', 'refused', 'host_cancelled', 'user_cancelled', 'closed', 'relaunched'].sample
          )
  end
end
puts 'Reservations for admin workouts created'
# Créez des réservations pour les séances d'entraînement de l'admin avec uniquement les statuts 'pending' et 'relaunched'
# Workout.where(host: admin_user).each do |workout|
#   3.times do
#     user = User.where.not(id: admin_user.id).sample
#     status = ['pending', 'relaunched'].sample # Sélectionne uniquement 'pending' ou 'relaunched'
#     Reservation.create(
#       user: user,
#       workout: workout,
#       quantity: rand(1..3),
#       total: workout.price * rand(1..3),
#       status: status
#     )
#   end
# end
# puts 'Reservations with pending and relaunched status for admin workouts created'