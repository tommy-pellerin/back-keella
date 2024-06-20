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
      render json: @user.as_json(include: [ :hosted_workouts, :participated_workouts ])
    else
      render json: { error: "Utilisateur non trouvé" }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
