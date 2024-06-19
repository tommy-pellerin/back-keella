class UserMailer < ApplicationMailer
  default from: ENV['MAILJET_NOREPLY_FROM']

  def welcome_email(user)
    @user = user
    @url  = "https://front-keella.vercel.app/sign-in"
    mail(to: @user.email, subject: "Bienvenue sur notre site")
  end

  def payment_confirmation_email(user, payment_intent)
    @user = user
    @paid_amount = (payment_intent.amount_received.to_f/100)
    mail(to: @user.email, subject: 'Confirmation de votre paiement')
  end

  def accepted_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @user.email, subject: 'Bonne nouvelle, votre réservation a été acceptée')
  end

  def refused_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @user.email, subject: 'Mauvaise nouvelle, votre réservation a été refusée')
  end

  def evaluate_host_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @user.email, subject: 'Séance terminée, merci pour votre confiance')
  end

  def reservation_cancelled_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @user.email, subject: 'Confirmation de l\'annulation de la séance')
  end

  def workout_cancelled_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @user.email, subject: 'La séance a été annulée par son hote')
  end

end
