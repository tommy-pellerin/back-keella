class RatingsController < ApplicationController
  before_action :set_rating, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :authorize_user!, only: %i[ update destroy ]

  # GET /ratings
  def index
    @ratings = Rating.all

    render json: @ratings.to_json(include: { user: { only: [:id, :username] } })
  end

  # GET /ratings/1
  def show
    render json: @ratings.to_json(include: { user: { only: [:id, :username] } })
  end

  # POST /ratings
  def create
    Rails.logger.info "Raw params: #{params.inspect}"
    Rails.logger.info "Received params: #{rating_params.inspect}"
    @rating = Rating.new(rating_params)
    @rating.user = current_user

    workout_id = rating_params[:workout_id]

    if workout_id.nil?
      render json: { error: "workout_id is missing" }, status: :unprocessable_entity
      return
    end

    begin
      workout = Workout.find(workout_id)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Workout not found" }, status: :unprocessable_entity
      return
    end

    if workout.is_closed
      if @rating.save
        render json: @rating, status: :created, location: @rating
      else
        render json: @rating.errors, status: :unprocessable_entity
        Rails.logger.error "Error while creating rating: " + @rating.errors.full_messages.join(", ") + " - " + @rating.inspect
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
      params.require(:rating).permit(:rateable_type, :rateable_id, :workout_id, :rating, :comment)
    rescue ActionController::ParameterMissing => e
      Rails.logger.error "ParameterMissing: #{e.message}"
      raise
    end
end
