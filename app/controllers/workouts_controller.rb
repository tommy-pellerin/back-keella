class WorkoutsController < ApplicationController
    before_action :set_workout, only: %i[ show update destroy ]
    before_action :authenticate_user!, only: %i[ create update destroy ]
    before_action :authorize_user!, only: %i[ update destroy ]


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
        end_date: @workout.end_date, available_places: @workout.available_places,
        category: @workout.category
      })
    else
      render json: @workout.as_json(include: { host: { only: [ :username, :id ] }, category: { only: [ :name ] } }).merge({
        end_date: @workout.end_date, available_places: @workout.available_places
      })
    end
  end

  # def show
  #   if @workout.workout_images.attached?
  #     image_url = rails_blob_url(@workout.workout_images, only_path: true)
  #   else
  #     image_url = @workout.category.image_url if @workout.category.image.attached?
  #   end

  #   render json: @workout.as_json(include: [:category]).merge({
  #     image_url: image_url,
  #     end_date: @workout.end_date, available_places: @workout.available_places })
  # end

  # POST /workouts
  def create
    Rails.logger.debug "Current User: #{current_user.inspect}"
    if current_user.nil?
      render json: { error: "Utilisateur non authentifié" }, status: :unauthorized
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
    if @workout.reservations.any? && !current_user.isAdmin?
      render json: { error: "Vous ne pouvez pas modifier un workout qui a déjà des réservations" }, status: :unauthorized
    elsif @workout.update(workout_params)
      render json: @workout
    else
      render json: @workout.errors, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1
  def destroy
    @workout.destroy!
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = Workout.find(params[:id])
    end

    def authorize_user!
      if current_user.isAdmin?
        return
      end

      unless @workout.host_id == current_user.id
        render json: { error: "Vous n'êtes pas autorisé à faire cette action" }, status: :unauthorized
      end
    end

    # Only allow a list of trusted parameters through.
    def workout_params
      params.require(:workout).permit(:title, :description, :start_date, :duration, :city, :zip_code, :price, :host_id, :max_participants, :category_id, workout_images: [])
    end
end
