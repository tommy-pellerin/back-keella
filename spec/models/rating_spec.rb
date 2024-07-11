require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) { create(:workout, host: host, is_closed: true) }
  let(:rating) { create(:rating, user: user, workout: workout) }

  context 'validations' do
    # it 'is valid with valid attributes' do
    #   expect(rating).to be_valid
    # end
    it 'is not valid without a user' do
      rating.user = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid without a workout' do
      rating.workout = nil
      expect(rating).to_not be_valid
    end
    it 'is not valid without a rateable' do
      rating.rateable = nil
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
  end
end
