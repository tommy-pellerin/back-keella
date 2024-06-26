class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show ]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    if @user
      user_json = @user.as_json(include: [ :reservations, :hosted_workouts, :participated_workouts, :ratings_received ])
      user_json[:avatar] = @user.avatar_url
      user_json[:average_rating] = @user.rating_received.any? ? @user.ratings_received.average(:rating).round(1) : 0
      render json: user_json
    else
      render json: { error: "Utilisateur non trouvé" }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
