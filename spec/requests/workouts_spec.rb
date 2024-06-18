require 'rails_helper'

RSpec.describe "/workouts", type: :request do
    let(:user) { create(:user) }
    let(:user1) { create(:user) }

    let(:category) { create(:category) }
    let(:valid_attributes) do
      {
        title: "workout",
        description: "description",
        start_date: Time.now + 1.day,
        duration: 60,
        city: "city",
        zip_code: "zip_code",
        price: 10,
        host_id: user.id,
        category_id: category.id,
        max_participants: 5
      }
    end

    let(:invalid_attributes) do
      {
        title: nil,
        description: "description",
        start_date: Time.now,
        duration: 60,
        city: "city",
        zip_code: "zip_code",
        price: 10,
        host_id: user.id,
        max_participants: 5
      }
    end

    let(:valid_headers) do {
    ACCEPT: "multipart/form-data"
    }
    end
  before do
    sign_in user
  end

  describe "GET /workouts" do
    it "renders a successful response" do
      get "/workouts"

      expect(response).to be_successful
    end

    it "returns a list of workouts" do
      workout1 = create(:workout, title: "workout1")
      workout2 = create(:workout, title: "workout2")

      get "/workouts"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(workout1.title)
      expect(response.body).to include(workout2.title)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      workout = create(:workout)

      get "/workouts/#{workout.id}"

      expect(response).to be_successful
      expect(response.body).to include(workout.title)
      expect(response.body).to include(workout.description)
      expect(response.body).to include(workout.start_date.as_json)
      expect(response.body).to include(workout.duration.to_s)
      expect(response.body).to include(workout.city)
      expect(response.body).to include(workout.zip_code)
      expect(response.body).to include(workout.price.to_s)
      expect(response.body).to include(workout.host_id.to_s)
      expect(response.body).to include(workout.max_participants.to_s)
      expect(response.body).to include(workout.category_id.to_s)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Workout" do
        expect {
          post workouts_path, params: { workout: valid_attributes }, headers: valid_headers }.to change(Workout, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response with the new workout" do
        post workouts_path, params: { workout: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Workout" do
        expect {
          post workouts_path,
              params: { workout: invalid_attributes }, headers: valid_headers
        }.to change(Workout, :count).by(0)
      end

      it "renders a JSON response with errors for the new workout" do
        post workouts_path,
            params: { workout: invalid_attributes }, headers: valid_headers
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not signed in" do
      before do
        sign_out user
      end

      it "does not create a new Workout" do
        expect {
          post workouts_path,
              params: { workout: valid_attributes }, headers: valid_headers
        }.to change(Workout, :count).by(0)
      end

      it "renders a JSON response with errors for the new workout" do
        post workouts_path,
            params: { workout: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(401)
        expect(response.content_type).to match(a_string_including("multipart/form-data"))
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) do
      {
        title: "new_workout",
        description: "new_description"
      }
    end

    context "with valid parameters" do
      it "updates the requested workout" do
        workout = create(:workout, valid_attributes)
        sign_in workout.host
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        workout.reload
        expect(workout.title).to eq("new_workout")
        expect(workout.description).to eq("new_description")
      end

      it "renders a JSON response with the workout" do
        workout = create(:workout, valid_attributes)
        sign_in workout.host
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the workout" do
        workout = create(:workout, valid_attributes)
        patch workout_path(workout),
              params: { workout: invalid_attributes }, headers: valid_headers
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not signed in" do
      before do
        sign_out user
      end

      it "does not update the requested workout" do
        workout = create(:workout, valid_attributes)
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        workout.reload
        expect(workout.title).to eq("workout")
        expect(workout.description).to eq("description")
      end

      it "renders a JSON response with errors for the workout" do
        workout = create(:workout, valid_attributes)
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        expect(response).to have_http_status(401)
        expect(response.content_type).to match(a_string_including("multipart/form-data"))
      end
    end

    context "when user is not the host of the workout" do
      before do
        sign_out user
        sign_in user1
      end

      it "does not update the requested workout" do
        workout = create(:workout, valid_attributes)
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        workout.reload
        expect(workout.title).to eq("workout")
        expect(workout.description).to eq("description")
      end

      it "renders a JSON response with errors for the workout" do
        workout = create(:workout, valid_attributes)
        patch workout_path(workout),
              params: { workout: new_attributes }, headers: valid_headers
        expect(response).to have_http_status(401)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested workout" do
      workout = create(:workout, valid_attributes)
      sign_in workout.host
      expect {
        delete workout_path(workout), headers: valid_headers }.to change(Workout, :count).by(-1)
    end

    context "when user is not signed in" do
      before do
        sign_out user
      end

      it "does not destroy the requested workout" do
        workout = create(:workout, valid_attributes)
      expect {
      delete workout_path(workout), headers: valid_headers }.to change(Workout, :count).by(0)
      end
    end

    context "when user is not the host of the workout" do
      before do
        sign_out user
        sign_in user1
      end

      it "does not destroy the requested workout" do
        workout = create(:workout, valid_attributes)
        expect {
          delete workout_path(workout), headers: valid_headers }.to change(Workout, :count).by(0)
      end
      it "renders a JSON response with errors for the workout" do
        workout = create(:workout, valid_attributes)
        delete workout_path(workout), headers: valid_headers
        expect(response).to have_http_status(401)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end
end
