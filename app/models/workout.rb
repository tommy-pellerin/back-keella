class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :reservations, dependent: :destroy

  has_many_attached :images

  validates :images, 
  length: { in: 0..3, notice: "doit contenir entre 0 et 3 images" }

  # Validations
  validates :host, presence: true
end
