class Category < ApplicationRecord
  has_many :workouts
  has_one_attached :category_image
  # Validations
  validates :name, presence: true

  scope :sort_by_creation, -> { order(created_at: :desc) }
  scope :sort_by_name, -> { order(name: :asc) }

end
