class User < ApplicationRecord
  after_create :send_welcome_email
  # Quand il est host
  has_many :hosted_workouts, foreign_key: "host_id", class_name: "Workout", dependent: :destroy
  # Quand il est participant
  has_many :reservations, dependent: :destroy
  has_many :participated_workouts, through: :reservations, source: :workout, dependent: :destroy

  has_many :ratings, dependent: :destroy
  has_many :ratings_received, -> { where(rateable_type: "User") }, class_name: "Rating", foreign_key: "rateable_id", dependent: :destroy

  has_one_attached :avatar, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
end
