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
      get ratings_url, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get rating_url(rating), as: :json
      expect(response).to be_successful
      expect(response.body).to include(rating.rating.to_s)
      expect(response.body).to include(rating.rateable_id.to_s)
      expect(response.body).to include(rating.user_id.to_s)
    end
  end

  describe "POST /create" do
    before do
      sign_in user
    end

    context "with valid parameters and user login" do
      it "creates a new Rating for workout" do
        expect {
          post ratings_url,
               params: { rating: valid_workout_rating_attributes }, headers: valid_headers, as: :json
        }.to change(Rating, :count).by(1)
      end

      it "creates a new Rating for participant" do
        sign_out user
        sign_in host

        expect {
          post ratings_url,
               params: { rating: valid_participant_rating_attributes }, headers: valid_headers, as: :json
        }.to change(Rating, :count).by(1)
      end

      it "renders a JSON response with the new rating" do
        post ratings_url,
             params: { rating: valid_workout_rating_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Rating" do
        expect {
          post ratings_url,
               params: { rating: invalid_attributes }, as: :json
        }.to change(Rating, :count).by(0)
      end

      it "renders a JSON response with errors for the new rating" do
        post ratings_url,
             params: { rating: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context 'with valid parameters and user logout' do
      before do
        sign_out user
      end

      it "does not create a new Rating" do
        expect {
          post ratings_url,
               params: { rating: valid_workout_rating_attributes }, as: :json
        }.to change(Rating, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) {
      { comment: "MyText Edit" }
    }

    before do
      sign_in user
    end

    context "with valid parameters" do
      it "updates the requested rating" do
        patch rating_url(rating),
              params: { rating: new_attributes }, headers: valid_headers, as: :json
        rating.reload
        expect(response).to have_http_status(:ok)
        expect(rating.comment).to eq("MyText Edit")
      end

      it "renders a JSON response with the rating" do
        patch rating_url(rating),
              params: { rating: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the rating" do
        patch rating_url(rating),
              params: { rating: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      sign_in user
    end

    it "destroys the requested rating" do
      rating = create(:rating, rateable: workout, user: user)
      expect {
        delete rating_url(rating), headers: valid_headers, as: :json
      }.to change(Rating, :count).by(-1)
    end
  end
end
