class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :reservations, dependent: :destroy

  # Validations
  validates :host, presence: true
end
