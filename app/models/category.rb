class Category < ApplicationRecord
  has_many :workout
  has_one_attached :category_image
end
