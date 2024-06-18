class Reservation < ApplicationRecord
  after_create :send_reservation_request_email
  after_update :send_email_on_condition

  belongs_to :user
  belongs_to :workout

  # Validations
  validates :user, presence: true
  validates :workout, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_participants }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :host_cannot_book_own_workout, on: :create
  validate :total_calculation, if: -> { workout.present? && quantity.present? }
  validate :no_overlap
  validate :already_full
  validate :past_workout

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

  def start_time
    self.workout.start_date
  end

  def end_time
    self.workout.start_date + self.workout.duration.minutes
  end

  def no_overlap
    return unless workout && user && start_time && end_time

    existing_reservations = Reservation.joins(:workout).where(user: user).where.not(id: id).where("#{Workout.table_name}.start_date < ? AND (#{Workout.table_name}.start_date + (#{Workout.table_name}.duration || ' minutes')::interval) > ?", end_time, start_time)

    if existing_reservations.any?
      errors.add(:base, "Vous avez déjà une réservation qui chevauche cette séance de sport")
    end
  end

  def already_full
    errors.add(:base, "La séance de sport est complète") if workout.present? && workout.reservations.count >= workout.max_participants
  end

  def past_workout
    errors.add(:workout, "La séance de sport est déjà passée") if workout.present? && workout.start_date + workout.duration.minutes < Time.now
  end

  def send_reservation_request_email
    puts "send request_email"
    HostMailer.reservation_request_email(self).deliver_now
  end

  def send_accepted_email
    UserMailer.accepted_email(self).deliver_now
  end

  def send_refused_email
    UserMailer.refused_email(self).deliver_now
  end

  def send_workout_cancelled_email
    UserMailer.workout_cancelled_email(self).deliver_now
    HostMailer.workout_cancelled_email(self).deliver_now
  end

  def send_reservation_cancelled_email
    HostMailer.reservation_cancelled_email(self).deliver_now
    UserMailer.reservation_cancelled_email(self).deliver_now
  end

  def send_evaluation_email
    UserMailer.evaluate_host_email(self).deliver_now
    HostMailer.evaluate_user_email(self).deliver_now
  end

  def send_email_on_condition
    puts "send email condition"
    case status
    # when "pending" # 0
    #   puts "pending request"
    #   send_reservation_request_email
    when "accepted" # 1
      send_accepted_email
    when "refused" # 2
      send_refused_email
    when "host_cancelled" # 3
      send_workout_cancelled_email
    when "user_cancelled" # 4
      send_reservation_cancelled_email
    when  "closed" # 5
      # send email only if only user and/or host have not saved any evaluation for the participated workout
      send_evaluation_email
    end
  end


  # for information, the above line is deprecated and replaced => the order of the element in the array is very very important !
  # see here : https://sparkrails.com/rails-7/2024/02/13/rails-7-deprecated-enum-with-keywords-args.html
  # enum :status, {
  #   pending: 0,
  #   accepted: 1,
  #   refused: 2,
  #   host_cancelled: 3,
  #   user_cancelled: 4,
  #   closed: 5,
  #   relaunched: 6
  # }

  enum :status, [ :pending, :accepted, :refused, :host_cancelled, :user_cancelled, :closed, :relaunched ]
end
