class WorkoutsController < ApplicationController
    before_action :set_workout, only: %i[ show update destroy ]
    before_action :authorize_user, only: %i[ update destroy ]
    before_action :authenticate_user!, only: %i[ create update destroy ]

  # GET /workouts
  def index
    @workouts = Workout.all

    render json: @workouts
  end

  # GET /workouts/1
  def show
    if @workout.workout_images.attached?
      render json: @workout.as_json.merge({
        image_url: rails_blob_url(@workout.workout_images, only_path: true),
        end_date: @workout.end_date, available_places: @workout.available_places
      })
    else
      render json: @workout.as_json(include: { host: { only: [ :username, :id ] } }).merge({
        end_date: @workout.end_date, available_places: @workout.available_places
      })
    end
  end

  # POST /workouts
  def create
    Rails.logger.debug "Current User: #{current_user.inspect}"
    if current_user.nil?
      render json: { error: 'Utilisateur non authentifié' }, status: :unauthorized
      return
    end
  
    @workout = current_user.hosted_workouts.build(workout_params)
    Rails.logger.debug "Workout to be saved: #{@workout.inspect}"
  
    if @workout.save
      render json: @workout, status: :created, location: @workout
    else
      render json: @workout.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1
  def update
    if @workout.update(workout_params)
      render json: @workout
    else
      render json: @workout.errors, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1
  def destroy
    @workout.destroy!
  end
  
  # GET /workouts/search
  def search
    @workouts = Workout.all

    if params[:city].present?
      @workouts = @workouts.where(city: params[:city])
    end

    if params[:date].present?
      @workouts = @workouts.where(start_date: params[:date])
    end

    if params[:tags].present?
      @workouts = @workouts.where('tags @> ARRAY[?]::varchar[]', params[:tags].split(','))
    end

    if params[:participants].present?
      @workouts = @workouts.where('max_participants >= ?', params[:participants].to_i)
    end
    
    render json: @workouts
  end

  private

  def authorize_user
    if @workout && @workout.user_id != current_user.id
      render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = Workout.find(params[:id])
    end

    def authorize_user!
      unless @workout.host_id == current_user.id
        render json: { error: "Vous n'êtes pas autorisé à faire cette action" }, status: :unauthorized
      end
    end

    # Only allow a list of trusted parameters through.
    def workout_params
      params.require(:workout).permit(:title, :description, :start_date, :duration, :city, :zip_code, :price, :host_id, :max_participants, :category_id, workout_images: [])
    end
end
