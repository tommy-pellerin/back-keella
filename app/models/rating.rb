class Rating < ApplicationRecord
  belongs_to :workout
  belongs_to :user
  belongs_to :rated_user, class_name: "User"

  validates :rating, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 500 }
  validates :workout_id, presence: true
  validates :user_id, presence: true
  validates :rated_user_id, presence: true
  validates :is_workout_rating, inclusion: { in: [ true, false ] }
  validates :user_id, uniqueness: { scope: [ :workout_id, :rated_user_id, :is_workout_rating ], message: "Vous avez déjà donné une note pour ce workout" }

  validate :user_cannot_rate_himself

  def user_cannot_rate_himself
    if user_id == rated_user_id
      errors.add(:user_id, "Vous ne pouvez pas vous noter vous-même")
    end
  end
end
