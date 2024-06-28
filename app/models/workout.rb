class Workout < ApplicationRecord
  after_update :closed_related_reservations, if: -> { saved_change_to_is_closed? && is_closed? }

  belongs_to :host, class_name: "User"
  belongs_to :category
  has_many :comments
  has_many :ratings, as: :rateable, dependent: :destroy


  has_many :reservations, dependent: :destroy
  has_many :participants, through: :reservations, source: :user

  # Associations pour les ratings recus pour le workout
  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :ratings_received, -> { where(rateable_type: "Workout") }, class_name: "Rating", foreign_key: "rateable_id"

  has_many_attached :workout_images

  # Validations
  validates :host, presence: true
  validates :title, presence: true, length: { minimum: 3, maximum: 50 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :city, presence: true, length: { minimum: 3, maximum: 50 }
  validates :zip_code, presence: true, length: { is: 5 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :start_date, presence: true
  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 30 }
  validates :max_participants, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validate :start_date_must_be_at_least_4_hours_from_now
  validate :duration_must_be_multiple_of_30

  scope :sort_by_creation, -> { order(created_at: :desc) }
  scope :sort_by_start_date, -> { order(start_date: :asc) }

  def end_date
    self.start_date + (self.duration * 60) # en minute
  end

  def available_places
    puts self.participants
    if self.reservations
      self.max_participants - self.reservations.where(status: [ "pending", "accepted" ]).sum(:quantity)
    else
      self.max_participants
    end
  end

  scope :with_available_places, ->(places) {
    joins("LEFT JOIN reservations ON reservations.workout_id = workouts.id")
    .group("workouts.id")
    .having("max_participants - COALESCE(SUM(reservations.quantity), 0) >= ?", places)
  }

  private

  def start_date_must_be_at_least_4_hours_from_now
    if start_date.present? && start_date <= Time.now + 4.hours
      errors.add(:start_date, "doit être au moins 4 heures après l'heure actuelle")
    end
  end

  def duration_must_be_multiple_of_30
    if duration.present? && duration % 30 != 0
      errors.add(:duration, "doit être un multiple de 30 minutes")
    end
  end

  def update_is_closed
    if end_date < Time.now
      self.update(is_closed: true)
    end
  end

  def rating_average
    self.ratings.average(:rating)
  end

  def closed_related_reservations
    if is_closed?
      reservations.where(status: "accepted").update_all(status: "closed")
      reservations.where(status: "pending").update_all(status: "host_cancelled")
    end
  end
end
