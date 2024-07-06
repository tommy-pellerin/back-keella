class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    if @user

      user_json = @user.as_json(include: {
        reservations: {},
        hosted_workouts: { include: :reservations }, # Inclut les réservations pour chaque hosted_workout
        participated_workouts: {},
        ratings_received: { include: { user: { only: [ :username ] } } }
      })

      user_json[:avatar] = @user.avatar.attached? ? url_for(@user.avatar) : nil
      user_json[:average_rating] = @user.ratings_received.any? ? @user.ratings_received.average(:rating).round(1) : 0
      render json: user_json
    else
      render json: { error: "Utilisateur non trouvé" }, status: :not_found
    end
  end

  # DELETE /users/:id
  def destroy
    if @user == current_user
      @user.destroy
      render json: { message: "Utilisateur supprimé" }, status: :ok
    else
      render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
