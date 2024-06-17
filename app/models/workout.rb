class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :users, through: :reservations
end
