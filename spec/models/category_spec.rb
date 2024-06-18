require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { create(:category) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      category.name = nil
      expect(category).to_not be_valid
    end
  end
end
