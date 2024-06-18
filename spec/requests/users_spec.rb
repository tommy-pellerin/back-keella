require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    it "returns a list of users when authenticated" do
      user1 = create(:user, username: "user1")
      user2 = create(:user, username: "user2")

      sign_in user1

      get "/users"
      expect(response).to have_http_status(:ok)

      expect(response.body).to include(user1.username)
      expect(response.body).to include(user2.username)
    end
  end

  describe "GET /users/:id" do
    let(:user) { create(:user) }
    it "returns a user when authenticated" do
      sign_in user

      get "/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.username)
    end

    it "returns a not found error when user does not exist" do
      sign_in user
      get "/users/999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
