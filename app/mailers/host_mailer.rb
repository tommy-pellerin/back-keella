class HostMailer < ApplicationMailer
  default from: ENV['MAILJET_NOREPLY_FROM']

  def reservation_request_email(reservation)
    # on récupère l'instance reservation pour ensuite pouvoir la passer à la view en @reservation
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout

    # on définit une variable @url qu'on utilisera dans la view d’e-mail
    @url  = 'https://front-keella.vercel.app/' 

    # c'est cet appel à mail() qui permet d'envoyer l’e-mail en définissant destinataire et sujet.
    mail(to: @host.email, subject: 'Demande de reservation !')
  end
  
  def evaluate_user_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @host.email, subject: 'Séance terminée, merci pour votre confiance')
  end

  def reservation_cancelled_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @host.email, subject: 'Réservation annulée par un utilisateur')
  end

  def workout_cancelled_email(reservation)
    @reservation = reservation
    @host = @reservation.workout.host
    @user = @reservation.user
    @workout = @reservation.workout
    mail(to: @host.email, subject: 'Confirmation de l\'annulation de la séance')
  end
end
