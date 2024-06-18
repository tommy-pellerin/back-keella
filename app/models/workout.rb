class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :category
  has_many :reservations, dependent: :destroy
  has_many :participants, through: :reservations, source: :user

  has_many_attached :workout_images

  # Validations
  validates :host, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :city, presence: true
  validates :zip_code, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :start_date, presence: true
  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 30 }
  validates :max_participants, presence: true, numericality: { greater_than_or_equal_to: 1 }

  # validate :start_date_must_be_at_least_4_hours_from_now
  # validate :duration_must_be_multiple_of_30

  # private

  # def start_date_must_be_at_least_4_hours_from_now
  #   if start_date.present? && start_date <= Time.now + 4.hours
  #     errors.add(:start_date, "doit être au moins 4 heures après l'heure actuelle")
  #   end
  # end

  # def duration_must_be_multiple_of_30
  #   if duration.present? && duration % 30 != 0
  #     errors.add(:duration, "doit être un multiple de 30 minutes")
  #   end
  # end

  def image_url
    if self.workout_images.attached?
      workout_images.first.service_url
    else
      self.category.image_url
    end
  end
end
