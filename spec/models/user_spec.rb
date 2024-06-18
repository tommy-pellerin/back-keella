require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it "is not valid without an username" do
      user = build(:user, username: nil)
      expect(user).to_not be_valid
    end

    it "is not valid with an username already taken" do
      existing_user = create(:user, username: "test")
      user = build(:user, username: "test")
      expect(user).to_not be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).to_not be_valid
    end

    it "is not valid with an email already taken" do
      existing_user = create(:user, email: "test@test.fr")
      user = build(:user, email: "test@test.fr")
      expect(user).to_not be_valid
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).to_not be_valid
    end

    it 'is not valid with a password less than 6 characters' do
      user = build(:user, password: "12345")
      expect(user).to_not be_valid
    end
  end

  context 'associations' do
    it "should have many hosted_workouts" do
      expect(User.reflect_on_association(:hosted_workouts).macro).to eq(:has_many)
    end

    it "should have many reservations" do
      expect(User.reflect_on_association(:reservations).macro).to eq(:has_many)
    end

    it "should have many participated_workouts" do
      expect(User.reflect_on_association(:participated_workouts).macro).to eq(:has_many)
    end
  end
end
