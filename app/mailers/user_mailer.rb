class UserMailer < ApplicationMailer
  default from: ENV['MAILJET_NOREPLY_FROM']

  def welcome_email(user)
    @user = user
    @url  = "http://keella.fly.io/login"
    mail(to: @user.email, subject: "Bienvenue sur notre site")
  end
end
