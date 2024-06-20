require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) { create(:workout, host: host) }
  let(:rating) { create(:rating, user: user, workout: workout, rated_user: host) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(rating).to be_valid
    end
    it 'is not valid without a user' do
      rating.user = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid without a workout' do
      rating.workout = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid without a rated user' do
      rating.rated_user = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid without a rating' do
      rating.rating = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid with a rating less than 1' do
      rating.rating = 0
      expect(rating).to_not be_valid
    end
    it 'is not valid with a rating greater than 5' do
      rating.rating = 6
      expect(rating).to_not be_valid
    end
    it 'is not valid without a is_workout_rating' do
      rating.is_workout_rating = nil
      expect(rating).to_not be_valid
    end
    it "can't rate himself" do
      rating.rated_user = user
      expect(rating).to_not be_valid
    end
  end

  context 'associations' do
    it 'belongs to a workout' do
      expect(rating.workout).to eq(workout)
    end
    it 'belongs to a user' do
      expect(rating.user).to eq(user)
    end
    it 'belongs to a rated user' do
      expect(rating.rated_user).to eq(host)
    end
  end
end
