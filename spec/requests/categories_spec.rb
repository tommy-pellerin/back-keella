require 'rails_helper'

RSpec.describe "/categories", type: :request do
  let(:admin) { create(:user, isAdmin: true)  }
  let(:user) { create(:user)  }

  let(:valid_attributes) do {
      name: "MyString"
    }
  end

  let(:invalid_attributes) do {
    name: nil
  }
  end

  let(:valid_headers) do {
      ACCEPT: "application/json"
  }
  end

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      category = create(:category)
      get categories_path, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      category = create(:category)
      get category_path(category), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Category" do
        expect {
          post categories_path,
              params: { category: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Category, :count).by(1)
      end

      it "renders a JSON response with the new category" do
        post categories_url,
            params: { category: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Category" do
        expect {
          post categories_url,
              params: { category: invalid_attributes }, headers: valid_headers, as: :json
        }.to change(Category, :count).by(0)
      end

      it "renders a JSON response with errors for the new category" do
        post categories_url,
            params: { category: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not admin" do
      before do
        sign_out admin
        sign_in user
      end

      it "does not create a new Category" do
        category = create(:category)
        expect {
          post categories_path,
            params: { category: valid_attributes }, headers: valid_headers, as: :json
          }.to change(Category, :count).by(0)
      end

      it 'renders a forbidden response' do
        category = create(:category)
        post categories_path,
          params: { category: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Vous n'êtes pas autorisé à acceder à cette page.")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) do {
        name: "MyString Edited"
      }
      end

      it "updates the requested category" do
        category = create(:category)
        patch category_url(category),
              params: { category: new_attributes }, headers: valid_headers, as: :json
        category.reload
        expect(category.name).to eq("MyString Edited")
      end

      it "renders a JSON response with the category" do
        category = create(:category)
        patch category_url(category),
              params: { category: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do {
        name: nil
      }
      end

      it "renders a JSON response with errors for the category" do
        category = create(:category)
        patch category_url(category),
              params: { category: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(422)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "when user is not admin" do
      before do
        sign_out admin
        sign_in user
      end

      it "does not update the requested category" do
        category = create(:category)
        patch category_url(category),
          params: { category: valid_attributes }, headers: valid_headers, as: :json
        category.reload
        expect(category.name).to eq("MyString")
      end

      it 'renders a forbidden response' do
        category = create(:category)
        patch category_url(category),
        params: { category: valid_attributes }, headers: valid_headers, as: :json
          expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Vous n'êtes pas autorisé à acceder à cette page.")
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested category" do
      category = category = create(:category)
      expect {
        delete category_url(category), headers: valid_headers, as: :json
      }.to change(Category, :count).by(-1)
    end

    context "when user is not admin" do
      before do
        sign_out admin
        sign_in user
      end

      it "does not destroy the requested category" do
        category = create(:category)
        expect {
          delete category_url(category), headers: valid_headers, as: :json
          }.to change(Category, :count).by(0)
      end

      it 'renders a forbidden response' do
        category = create(:category)
        delete category_url(category), headers: valid_headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Vous n'êtes pas autorisé à acceder à cette page.")
      end
    end
  end
end
