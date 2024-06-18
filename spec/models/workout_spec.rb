require 'rails_helper'

RSpec.describe Workout, type: :model do
  let(:user) { build(:user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      workout = build(:workout, host: user)
      expect(workout).to be_valid
    end

    it 'is not valid without a host' do
      workout = build(:workout, host: nil)
      expect(workout).to_not be_valid
    end

    it 'is not valid without a title' do
      workout = build(:workout, host: user, title: nil)
      expect(workout).to_not be_valid
    end

    it 'is not valid without a description' do
      workout = build(:workout, host: user, description: nil)
      expect(workout).to_not be_valid
    end

    it 'is not valid without a city' do
      workout = build(:workout, host: user, city: nil)
      expect(workout).to_not be_valid
    end

    it "is not valid without a zip code" do
      workout = build(:workout, host: user, zip_code: nil)
      expect(workout).to_not be_valid
    end

    it "is not valid without a price" do
      workout = build(:workout, host: user, price: nil)
      expect(workout).to_not be_valid
    end

    it "is not valid with a price less than 0" do
      workout = build(:workout, host: user, price: -1)
      expect(workout).to_not be_valid
    end

    it "is not valid with a price more than 100" do
      workout = build(:workout, host: user, price: 101)
      expect(workout).to_not be_valid
    end

    it "is not valid without a start date" do
      workout = build(:workout, host: user, start_date: nil)
      expect(workout).to_not be_valid
    end

    it "is not valid with a start date in the past" do
      workout = build(:workout, host: user, start_date: Time.now - 1.day)
      expect(workout).to_not be_valid
    end

    it 'is not valid with a start date at least 4hours from now' do
      workout = build(:workout, host: user, start_date: Time.now + 3.hours)
      expect(workout).to_not be_valid
    end

    it 'is valid with a start date at least 4hours from now' do
      workout = build(:workout, host: user, start_date: Time.now + 5.hours)
      expect(workout).to be_valid
    end

    it "is not valid without a duration" do
      workout = build(:workout, host: user, duration: nil)
      expect(workout).to_not be_valid
    end

    it "is not valid with a duration less than 30" do
      workout = build(:workout, host: user, duration: 29)
      expect(workout).to_not be_valid
    end

    it "is not valid with a duration not a multiple of 30" do
      workout = build(:workout, host: user, duration: 35)
      expect(workout).to_not be_valid
    end

    it "is value with a duration of 30" do
      workout = build(:workout, host: user, duration: 30)
      expect(workout).to be_valid
    end

    it "is value with a duration of 60" do
      workout = build(:workout, host: user, duration: 60)
      expect(workout).to be_valid
    end

    it "is not valid without a max participants" do
      workout = build(:workout, host: user, max_participants: nil)
      expect(workout).to_not be_valid
    end

    it 'is not valid with a max participants less than 1' do
      workout = build(:workout, host: user, max_participants: 0)
      expect(workout).to_not be_valid
    end
  end

  context 'associations' do
    it "should belong to a host" do
      expect(Workout.reflect_on_association(:host).macro).to eq(:belongs_to)
    end

    it "should have many reservations" do
      expect(Workout.reflect_on_association(:reservations).macro).to eq(:has_many)
    end
  end
end
