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
      user_json = @user.as_json(include: [ :reservations, :hosted_workouts, :participated_workouts, ratings_received: {
        include: { user: { only: [:id, :username] } }
      }
    ])
      user_json[:avatar] = @user.avatar.attached? ? url_for(@user.avatar) : nil
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
