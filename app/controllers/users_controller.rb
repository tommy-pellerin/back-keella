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
        hosted_workouts: { include: :reservations },
        participated_workouts: { include: { host: { only: [ :username, :email ] } } },
        ratings_received: { include: { user: { only: [ :username ] } } }
      }).merge({
        avatar: @user.avatar.attached? ? url_for(@user.avatar) : nil,
        average_rating: @user.ratings_received.any? ? @user.ratings_received.average(:rating).round(1) : 0,
        ratings_received_user_avatars: @user.ratings_received.includes(:user).map do |rating|
          {
            rating_id: rating.id,
            user_avatar: rating.user.avatar.attached? ? url_for(rating.user.avatar) : nil
          }
        end
      })

      
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
