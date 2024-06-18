require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) { create(:workout, host: host, price: 20, max_participants: 10) }
  let(:reservation) { create(:reservation, user: user, workout: workout, quantity: 5, total: 100) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(reservation).to be_valid
    end

    it 'is not valid without a user' do
      reservation.user = nil
      expect(reservation).to_not be_valid
    end

    it 'is not valid without a workout' do
      reservation.workout = nil
      expect(reservation).to_not be_valid
    end

    it 'is not valid without a quantity' do
      reservation.quantity = nil
      expect(reservation).to_not be_valid
    end

    it 'is not valid with a quantity less than 1' do
      reservation.quantity = 0
      expect(reservation).to_not be_valid
    end

    it 'is not valid with a quantity greater than the workout max participants' do
      reservation.quantity = workout.max_participants + 1
      expect(reservation).to_not be_valid
    end

    it 'is not valid without a total' do
      reservation.total = nil
      expect(reservation).to_not be_valid
    end

    it 'is not valid with an incorrect total' do
      reservation.total = workout.price * (workout.max_participants - 1)
      expect(reservation).to_not be_valid
      expect(reservation.errors.messages[:total]).to include('Le total est incorrect')
    end

    it 'is valid with a total equal to the quantity multiplied by the workout price' do
      reservation.total = workout.price * reservation.quantity
      expect(reservation).to be_valid
    end

    it 'is not valid if the user is the host' do
      host_reservation = build(:reservation, user: host, workout: workout)
      expect(host_reservation).to_not be_valid
      expect(host_reservation.errors.messages[:host]).to include("Vous ne pouvez pas réserver votre propre séance de sport")
    end

    it "is not valid if the workout is already full" do
      workout.max_participants.times do
        create(:reservation, workout: workout)
      end
      new_reservation = build(:reservation, user: user, workout: workout)
      expect(new_reservation).to_not be_valid
    end

    it "is not valid if the workout is past" do
      workout = create(:workout, host: host, price: 20, max_participants: 10)
      workout.update(start_date: Time.now - 1.day)
      reservation = build(:reservation, user: user, workout: workout)
      expect(reservation).to_not be_valid
      expect(reservation.errors.messages[:workout]).to include("La séance de sport est déjà passée")
    end

    it 'is valid if the user does not have a reservation overlaping the new reservation' do
      new_workout = create(:workout, host: host, price: 20, max_participants: 10, start_date: workout.start_date + workout.duration.minutes, duration: 60)
      new_reservation = build(:reservation, user: user, workout: new_workout, quantity: 5, total: 100)
      expect(new_reservation).to be_valid
    end

    it "is not valid if the user have a reservation overlaping the new reservation" do
      new_start_date = reservation.workout.start_date + (reservation.workout.duration / 2).minutes
      new_workout = create(:workout, host: host, price: 20, max_participants: 10, start_date: new_start_date, duration: 60)
      new_reservation = build(:reservation, user: user, workout: new_workout, quantity: 5, total: 100)
      expect(new_reservation).to_not be_valid
      expect(new_reservation.errors.messages[:base]).to include("Vous avez déjà une réservation qui chevauche cette séance de sport")
    end
  end

  context 'associations' do
    it 'should belong to a user' do
      expect(Reservation.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'should belong to a workout' do
      expect(Reservation.reflect_on_association(:workout).macro).to eq(:belongs_to)
    end
  end
end
