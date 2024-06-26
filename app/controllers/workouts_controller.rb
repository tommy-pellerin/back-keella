class WorkoutsController < ApplicationController
    before_action :set_workout, only: %i[ show update destroy ]
    before_action :authenticate_user!, only: %i[ create update destroy ]
    before_action :authorize_user!, only: %i[ update destroy ]


  # GET /workouts
  def index
    @workouts = Workout.all

    # Tri
    if params[:sort] == "creation"
      @workouts = @workouts.sort_by_creation
    elsif params[:sort] == "start_date"
      @workouts = @workouts.sort_by_start_date
    end

    # Pagination
    page = (params[:page] || 1).to_i
    page_size = (params[:page_size] || 10).to_i
    @workouts = @workouts.offset((page - 1) * page_size).limit(page_size)

    # Include image URLs
    workouts_with_images = @workouts.map do |workout|
      image_url = if workout.workout_images.attached?
                    rails_blob_url(workout.workout_images.first)
      elsif workout.category.category_image.attached?
                    rails_blob_url(workout.category.category_image)
      else
                    nil
      end

      workout.as_json(include: { host: { only: [ :username, :id ] }, category: { only: [ :name ] } }).merge({
        image_url: image_url,
        end_date: workout.end_date,
        available_places: workout.available_places,
        category: workout.category
      })
    end

    render json: workouts_with_images
  end

  # GET /workouts/1
  def show
    if @workout.workout_images.attached?
      image_urls = @workout.workout_images.map do |image|
        rails_blob_url(image)
      end
      render json: @workout.as_json(include: {
        host: { only: [ :username, :id ], method: [ :avatar_url ] },
        category: { only: [ :name ] },
        reservations: {
        include: {
          user: { only: [ :username, :id ], method: [ :avatar_url ] }
        },
        only: [ :id, :status ]
      },
      ratings_received: {
      include: {
        user: { only: [:username] } 
      },
      methods: [:rateable_type, :rateable_id], 
      only: [:id, :rating, :comment, :user_id, :workout_id] 
    }
      }).merge({
        image_urls: image_urls,
        end_date: @workout.end_date,
        available_places: @workout.available_places,
        average_rating: @workout.ratings_received.any? ? @workout.ratings_received.average(:rating).round(1) : 0
      })
    else
      render json: @workout.as_json(include: {
        host: { only: [ :username, :id ], method: [ :avatar_url ] },
        category: { only: [ :name ] },
        reservations: {
        include: {
          user: { only: [ :username, :id ], method: [ :avatar_url ] }
        },
        only: [ :id, :status ]
      },
      ratings_received: {
      include: {
        user: { only: [:username] } 
      },
      methods: [:rateable_type, :rateable_id], 
      only: [:id, :rating, :comment, :user_id, :workout_id] 
    }
      }).merge({
        end_date: @workout.end_date,
        available_places: @workout.available_places,
        category: @workout.category.as_json.merge(
          @workout.category.category_image.attached? ? { category_image: rails_blob_url(@workout.category.category_image) } : {}
        ),
        average_rating: @workout.ratings_received.any? ? @workout.ratings_received.average(:rating).round(1) : 0
      })
    end
  end

  # POST /workouts
  def create
    if current_user.nil?
      render json: { error: "Utilisateur non authentifié" }, status: :unauthorized
      return
    end

    @workout = current_user.hosted_workouts.build(workout_params)

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
