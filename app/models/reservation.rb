class Reservation < ApplicationRecord
  after_create :send_reservation_request_email
  after_update :manage_email_and_credit_on_condition
  before_validation :set_total

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
  validate :quantity_does_not_exceed_available_places
  validate :is_credit_enough, on: :create

  def update_status_without_validation(new_status)
    self.status = new_status
    save(validate: false)
  end

  def debit_user
    begin
      amount_to_debit = set_total
      if amount_to_debit > 0
        user.update!(credit: user.credit.to_f - amount_to_debit)
        return "Host has been paid successfully."
      else
        return "Invalid payment amount."
      end
    rescue => e
      # Log the error message e.message if logging is set up
      return "An error occurred during payment: #{e.message}"
    end
  end

  private

  # Ensure the user has enough credit to make the reservation
  def is_credit_enough
    total_price = set_total
    if user.credit < total_price
      errors.add(:base, "Vous n'avez pas assez de crédit pour réserver ce cours.")
    end
  end

  def host_cannot_book_own_workout
    if workout.present? && user.id == workout.host.id
      errors.add(:host, "Vous ne pouvez pas réserver votre propre séance de sport")
    end
  end

  def set_total
    return unless workout.present? && quantity.present?
    self.total = quantity * workout.price
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

  def past_workout
    errors.add(:workout, "La séance de sport est déjà passée") if workout.present? && workout.start_date + workout.duration.minutes < Time.now
  end

  def available_places
    workout.present? ? workout.max_participants - workout.reservations.sum(:quantity) : 0
  end

  def already_full
    errors.add(:base, "La séance de sport est complète") if available_places <= 0
  end

  def quantity_does_not_exceed_available_places
    return unless workout.present? && quantity.present?
    errors.add(:quantity, "Il n'y a pas assez de places disponibles") if quantity > available_places
  end

  def send_reservation_request_email
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

  def refund_user
    amount_to_refund = set_total || 0
    current_credit = user.credit || 0
    new_credit = current_credit + amount_to_refund
    if new_credit >= 0
      user.update(credit: new_credit)
    else
      errors.add(:base, "Credit invalide")
    end
  end

  def credit_host
    begin
      amount_to_credit = set_total
      if amount_to_credit > 0
        workout.host.update!(credit: workout.host.credit.to_f + amount_to_credit)
        return "Host has been paid successfully."
      else
        return "Invalid payment amount."
      end
    rescue => e
      # Log the error message e.message if logging is set up
      return "An error occurred during payment: #{e.message}"
    end
  end

  def manage_email_and_credit_on_condition
    case status
    when "pending" # 0
    #   puts "pending request"
    #   send_reservation_request_email
    when "accepted" # 1
      send_accepted_email
    when "refused" # 2
      refund_user
      send_refused_email
    when "host_cancelled" # 3
      refund_user
      send_workout_cancelled_email
    when "user_cancelled" # 4
      refund_user
      send_reservation_cancelled_email
    when  "closed" # 5
      credit_host
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
