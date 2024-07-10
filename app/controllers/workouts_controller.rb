class WorkoutsController < ApplicationController
    before_action :set_workout, only: %i[ show update destroy ]
    before_action :authenticate_user!, only: %i[ create update destroy ]
    before_action :authorize_user!, only: %i[ update destroy ]


  # GET /workouts
  def index
    @workouts = Workout.all.includes(:host, :category, :reservations)

    @workouts = filter_by_params(@workouts)
    @workouts = sort_workouts_by_params(@workouts)
    @workouts = paginate_workouts(@workouts)
    render json: workouts_with_images(@workouts)
  end

  def show
    workout_json = @workout.as_json(include: {
      host: { only: [ :username, :id, :avatar ] },
      category: { only: [ :name ] },
      reservations: {
        include: {
          user: { only: [ :username, :email, :id, :avatar ] }
        },
        only: [ :id, :status ]
      },
      ratings_received: { only: [ :id, :rating, :comment, :user_id, :created_at ], include: { user: { only: [ :username ] } } }
    }).merge({
      end_date: @workout.end_date,
      available_places: @workout.available_places,
      average_rating: @workout.ratings_received.any? ? @workout.ratings_received.average(:rating).round(1) : 0,
      host_avatar: @workout.host.avatar.attached? ? url_for(@workout.host.avatar) : nil,
      reservations_user_avatars: @workout.reservations.includes(:user).map do |reservation|
        { reservation_id: reservation.id, user_avatar: reservation.user.avatar.attached? ? url_for(reservation.user.avatar) : nil }
      end
    })

    if @workout.workout_images.attached?
      workout_json[:image_urls] = @workout.workout_images.map { |image| rails_blob_url(image) }
    else
      workout_json[:category] = @workout.category.as_json.merge(
        @workout.category.category_image.attached? ? { category_image: rails_blob_url(@workout.category.category_image) } : {}
      )
    end

    render json: workout_json
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
    # Check if all reservations have a status other than "pending", "accepted", and "closed"
    if @workout.reservations.any? { |reservation| ["pending", "accepted", "closed"].include?(reservation.status) } && !current_user.isAdmin?
      render json: { error: "Vous ne pouvez pas modifier un workout qui a déjà des réservations" }, status: :unauthorized
    elsif @workout.update!(workout_params)
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
      params.require(:workout).permit(:title, :description, :start_date, :duration, :city, :zip_code, :price, :host_id, :max_participants, :category_id, :is_closed, workout_images: [])
    end

    def filter_by_params(workouts)
      workouts = filter_by_city(workouts) if params[:city].present?
      workouts = filter_by_date(workouts) if params[:date].present?
      workouts = filter_by_time(workouts) if params[:time].present?
      workouts = filter_by_category(workouts) if params[:category_id].present?
      workouts = filter_by_participants(workouts) if params[:participants].present?
      workouts
    end

    def filter_by_city(workouts)
      workouts.where(city: params[:city])
    end

    def filter_by_date(workouts)
      date = Date.parse(params[:date])
      workouts.where(start_date: date.beginning_of_day..date.end_of_day)
    end

    def filter_by_time(workouts)
      workouts.where("duration =?", params[:time])
    end

    def filter_by_category(workouts)
      workouts.where(category_id: params[:category_id])
    end

    def filter_by_participants(workouts)
      workouts.with_available_places(params[:participants].to_i)
    end

    def sort_workouts_by_params(workouts)
      if params[:sort] == "creation"
        workouts.sort_by_creation
      elsif params[:sort] == "start_date"
        workouts.sort_by_start_date
      else
        workouts
      end
    end

    def paginate_workouts(workouts)
      page = (params[:page] || 1).to_i
      page_size = (params[:page_size] || 10).to_i
      workouts.offset((page - 1) * page_size).limit(page_size)
    end

    def workouts_with_images(workouts)
      workouts.map do |workout|
        image_url = if workout.workout_images.attached?
                      rails_blob_url(workout.workout_images.first)
        elsif workout.category.category_image.attached?
                      rails_blob_url(workout.category.category_image)
        else
                      nil
        end

        workout.as_json(include: { host: { only: [ :username, :id ] }, category: { only: [ :name, :id ] } }).merge({
          image_url: image_url,
          end_date: workout.end_date,
          available_places: workout.available_places,
          category: workout.category,
          avatar: workout.host.avatar.attached?? url_for(workout.host.avatar) : nil
        })
      end
    end
end
