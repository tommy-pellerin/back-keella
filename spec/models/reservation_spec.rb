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
