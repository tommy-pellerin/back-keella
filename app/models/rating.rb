class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true
  belongs_to :workout

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user, uniqueness: { scope: [ :rateable_type, :rateable_id, :workout_id ], message: "Vous avez déjà noté cette ressource" }
  # validate :workout_is_closed, on: :create

  def valid_rating_context?(user, rating, workout_id)
    if rating.rateable_type == "Workout"
      user.participated_workouts.exists?(id: rating.rateable_id)
    elsif rating.rateable_type == "User"
      workout = Workout.find(workout_id)
      workout.participants.find(rating.rateable_id)
    else
      false
    end
  end

  private

  # def workout_is_closed
  #   return if workout.is_closed?
  #     errors.add(:workout, "n'est pas encore terminé")
  # end
end
