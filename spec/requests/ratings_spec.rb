require 'rails_helper'
RSpec.describe "/ratings", type: :request do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) { create(:workout, host: host) }
  let(:rating) { create(:rating, workout: workout, user: host, rated_user: user) }

 let(:valid_attributes) {
    {
    workout_id: workout.id,
    user_id: host.id,
    rated_user_id: user.id,
    is_workout_rating: true,
    rating: 5,
    comment: "MyText"
    }
  }

  let(:invalid_attributes) {
    {
    workout: workout.id,
    user: user.id,
      rated_user: user.id,
    is_workout_rating: true
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
      expect(response.body).to include(rating.workout_id.to_s)
      expect(response.body).to include(rating.user_id.to_s)
      expect(response.body).to include(rating.rated_user_id.to_s)
      expect(response.body).to include(rating.is_workout_rating.to_s)
    end
  end

  describe "POST /create" do
    before do
      sign_in host
    end

    context "with valid parameters and user login" do
      it "creates a new Rating" do
        expect {
          post ratings_url,
               params: { rating: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Rating, :count).by(1)
      end

      it "renders a JSON response with the new rating" do
        post ratings_url,
             params: { rating: valid_attributes }, headers: valid_headers, as: :json
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
        expect(response).to have_http_status(422)
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
            params: { rating: valid_attributes }, as: :json
        }.to change(Rating, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { comment: "MyText Edit" }
      }
      before do
        sign_in host
      end

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
        rating = Rating.create! valid_attributes
        patch rating_url(rating),
              params: { rating: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(401)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      sign_in host
    end
    it "destroys the requested rating" do
      rating = create(:rating, workout: workout, user: host, rated_user: user)
      expect {
        delete rating_url(rating), headers: valid_headers, as: :json
      }.to change(Rating, :count).by(-1)
    end
  end
end
