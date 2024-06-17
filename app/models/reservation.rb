class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :workout

  # Validations
  validates :user, presence: true
  validates :workout, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_participants }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :host_cannot_book_own_workout, on: :create
  validate :total_calculation, if: -> { workout.present? && quantity.present? }

  private

  def host_cannot_book_own_workout
    if workout.present? && user.id == workout.host.id
      errors.add(:host, "Vous ne pouvez pas réserver votre propre séance de sport")
    end
  end

  def max_participants
    workout.present? ? workout.max_participants : 0
  end

  def total_calculation
      total = workout.price * quantity
      errors.add(:total, "Le total est incorrect") if total != self.total
  end
end
