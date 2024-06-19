class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :authorize_user!, only: %i[ update destroy ]
  before_action :build_reservation, only: [ :create ]
  before_action :is_places_available, only: [ :create ]

  # GET /reservations
  def index
    @reservations = Reservation.all

    render json: @reservations
  end

  # GET /reservations/1
  def show
    render json: @reservation
  end

  # POST /reservations
  def create
    puts "#"*50
    puts "je suis dans create reservation"
    # puts params
    # puts reservation_params
    puts current_user
    puts "#"*50
    @reservation = current_user.reservations.build(reservation_params)
    puts @reservation
    if @reservation.save
      render json: @reservation, status: :created, location: @reservation
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /reservations/1
  def update
    if @reservation.update(reservation_params)
      render json: @reservation
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reservations/1
  def destroy
    @reservation.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def authorize_user!
      unless @reservation.user_id == current_user.id
        render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
      end
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      # puts "dans reservation params"
      params.require(:reservation).permit(:workout_id, :quantity, :total, :status)
    end

    def build_reservation
      puts "$"*50
      puts "build reservation"
      @builded_reservation = current_user.reservations.build(reservation_params)
    end

    def is_places_available
      @workout = @builded_reservation.workout
      puts "#"*50
      puts @builded_reservation.quantity
      puts @workout
      if @workout.available_places - @builded_reservation.quantity >= 0
        puts "Des places sont disponible"
        true
      else
        puts "Il n'y a plus de place"
        render json: { error: "No available places" }, status: :unprocessable_entity
        false
      end
    end
end
