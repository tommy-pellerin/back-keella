require 'rails_helper'

RSpec.describe "/ratings", type: :request do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) do
    w = create(:workout, host: host, is_closed: false)
    w.update_column(:is_closed, true)
    w.update_column(:start_date, Time.now - 1.day)
    w
  end
  let(:reservation) { create(:reservation, workout: workout, user: user, quantity: 1) }
  let(:rating) { create(:rating, rateable: workout, user: user) }

  let(:valid_workout_rating_attributes) {
    {
      rateable_type: "Workout",
      rateable_id: workout.id,
      rating: 5,
      comment: "Great workout!",
      workout_id: workout.id
    }
  }

  let(:valid_participant_rating_attributes) {
    {
      rateable_type: "User",
      rateable_id: user.id,
      rating: 4,
      comment: "Good participant",
      workout_id: workout.id
    }
  }

  let(:invalid_attributes) {
    {
      rateable_type: "Workout",
      rateable_id: workout.id,
      rating: 0,
      comment: nil
    }
  }

  let(:valid_headers) {
    { ACCEPT: "application/json" }
  }

  describe "GET /index" do
    it "renders a successful response" do
   end
  end

  describe "GET /show" do
    it "renders a successful response" do
   end
  end

  describe "POST /create" do
    context "with valid parameters and user login" do
      it "creates a new Rating for workout" do
     end

      it "creates a new Rating for participant" do
     end

      it "renders a JSON response with the new rating" do
     end
    end

    context "with invalid parameters" do
      it "does not create a new Rating" do
     end

      it "renders a JSON response with errors for the new rating" do
     end
    end

    context 'with valid parameters and user logout' do
     it "does not create a new Rating" do
     end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested rating" do
     end

      it "renders a JSON response with the rating" do
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the rating" do
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested rating" do
    end
  end
end
