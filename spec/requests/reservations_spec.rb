require 'rails_helper'
RSpec.describe "/reservations", type: :request do
  let(:user) { create(:user) }
  let(:host) { create(:user) }
  let(:workout) { create(:workout, host: host) }
  let(:valid_attributes) do
    {
      user_id: user.id,
      workout_id: workout.id,
      quantity: 1,
      total: 20
    }
  end

  let(:invalid_attributes) do
    {
      user_id: nil,
      workout_id: nil,
      quantity: nil,
      total: nil
    }
  end

  let(:valid_headers) do {
     ACCEPT: "application/json"
  }
  end

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      get "/reservations"

      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      reservation = create(:reservation, valid_attributes)

      get "/reservations/#{reservation.id}"

      expect(response).to be_successful
      expect(response.body).to include(reservation.user_id.to_s)
      expect(response.body).to include(reservation.workout_id.to_s)
      expect(response.body).to include(reservation.quantity.to_s)
      expect(response.body).to include(reservation.total.to_s)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Reservation" do
        expect {
          post reservations_path,
               params: { reservation: valid_attributes }, headers: valid_headers
        }.to change(Reservation, :count).by(1)
      end

      it "renders a JSON response with the new reservation" do
        post reservations_path,
             params: { reservation: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Reservation" do
        expect {
          post reservations_path,
               params: { reservation: invalid_attributes }, as: :json
        }.to change(Reservation, :count).by(0)
      end

      it "renders a JSON response with errors for the new reservation" do
        post reservations_path,
             params: { reservation: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not signed in" do
      before do
        sign_out user
      end

      it "does not create a new Reservation" do
        expect {
          post reservations_path,
               params: { reservation: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Reservation, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_quantity) do {
        quantity: 2
      }
      end
      it "user can update quantity" do
        reservation = create(:reservation, valid_attributes)
        sign_in reservation.user
        patch reservation_path(reservation),
              params: { reservation: new_quantity }, headers: valid_headers
        reservation.reload
        expect(reservation.quantity).to eq(2)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the reservation" do
        reservation = create(:reservation, valid_attributes)
        sign_in reservation.user
        patch reservation_path(reservation),
              params: { reservation: invalid_attributes }, headers: valid_headers
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not signed in" do
      before do
        sign_out user
      end

      it "does not update the requested reservation" do
        reservation = create(:reservation, valid_attributes)
        patch reservation_path(reservation),
              params: { reservation: valid_attributes }, headers: valid_headers
        reservation.reload
        expect(reservation.quantity).to eq(1)
        expect(reservation.total).to eq(20)
      end
    end

    context "when user is not the owner of the reservation" do
      before do
        sign_out user
        sign_in create(:user)
      end

      it "does not update the requested reservation" do
        reservation = create(:reservation, valid_attributes)
        patch reservation_path(reservation),
          params: { reservation: valid_attributes }, headers: valid_headers
        reservation.reload
        expect(reservation.quantity).to eq(1)
        expect(reservation.total).to eq(20)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested reservation" do
      reservation = create(:reservation, valid_attributes)
      sign_in reservation.user
      expect {
        delete reservation_path(reservation), headers: valid_headers
      }.to change(Reservation, :count).by(-1)
    end
  end
end
