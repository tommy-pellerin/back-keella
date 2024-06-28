class RatingsController < ApplicationController
  before_action :set_rating, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :authorize_user!, only: %i[ update destroy ]

  # GET /ratings
  def index
    @ratings = Rating.all

    render json: @ratings
  end

  # GET /ratings/1
  def show
    render json: @rating
  end

  # POST /ratings
  def create
    @rating = Rating.build(rating_params)
    @rating.user = current_user
    workout_id = rating_params[:workout_id]
    workout = Workout.find(workout_id)

    if workout.is_closed
      if @rating.valid_rating_context?(current_user, @rating, workout_id)
        if @rating.save
          render json: @rating, status: :created, location: @rating
        else
          render json: @rating.errors, status: :unprocessable_entity
          Rails.logger.error "Error while creating rating: " + @rating.errors.full_messages.join(", ") + " - " + @rating.inspect
        end
      else
        render json: { error: "Vous ne pouvez pas noter cette ressource" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Le workout n'est pas encore terminé" }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ratings/1
  def update
    if @rating.update(rating_params)
      render json: @rating
    else
      render json: @rating.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ratings/1
  def destroy
    @rating.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    def authorize_user!
      unless @rating.user_id == current_user.id
        render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
      end
    end

    # Only allow a list of trusted parameters through.
    def rating_params
      params.require(:rating).permit(:rating, :comment, :rateable_type, :rateable_id, :workout_id)
    end
end
