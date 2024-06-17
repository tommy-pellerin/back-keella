class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :reservations
end
