class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :reservations, dependent: :destroy

  has_many_attached :images



  # Validations
  validates :host, presence: true
end
