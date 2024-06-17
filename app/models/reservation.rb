class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :workout

  # Validations
  validate :host_cannot_book_own_workout, on: :create

  private

  def host_cannot_book_own_workout
      errors.add(:host, "can't book his own workout") if user == workout.host
  end
end
