class Reservation < ApplicationRecord
  after_update :send_email_on_condition

  belongs_to :user
  belongs_to :workout

  # Validations
  validate :host_cannot_book_own_workout, on: :create

  private

  def host_cannot_book_own_workout
      errors.add(:host, "can't book his own workout") if user == workout.host
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
    if self.workout.reservations.order(:created_at).first == self
      HostMailer.workout_cancelled_email(self).deliver_now
    end
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
    case status
      when "accepted"
        send_accepted_email
      when "refused"
        send_refused_email
      when "host_cancelled"
        send_workout_cancelled_email
      when "user_cancelled"
        send_reservation_cancelled_email
      when  "closed" 
        #send email only if only user and/or host have not saved any evaluation for the participated workout
        send_evaluation_email
      when "pending"
        send_reservation_request_email
    end
  end


  #for information, the above line is deprecated and replaced => the order of the element in the array is very very important ! 
  #see here : https://sparkrails.com/rails-7/2024/02/13/rails-7-deprecated-enum-with-keywords-args.html
  enum :status, {
    pending: 0,
    accepted: 1,
    refused: 2,
    host_cancelled: 3,
    user_cancelled: 4,
    closed: 5,
    relaunched: 6
  }

end
