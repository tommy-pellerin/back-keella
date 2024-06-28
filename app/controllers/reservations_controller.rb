class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ create update destroy ]
  before_action :authorize_user!, only: %i[ update destroy ]
  before_action :authorize_update, only: %i[ update ]

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
    @reservation = current_user.reservations.build(reservation_params)
    if @reservation.valid? && @reservation.debit_user # Ensure reservation is valid and user is debited successfully
      if @reservation.save
        render json: @reservation, status: :created, location: @reservation
      else
        render json: { error: @reservation.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    else
      # Handle errors from debit operation or invalid reservation
      render json: { error: @reservation.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /reservations/1
  def update
    if @reservation_updatable_attributes.include?("status")
      # Mettre à jour le statut sans déclencher les validations
      @reservation.update_status_without_validation(reservation_update_params[:status])
      render json: @reservation
    else
      # Si d'autres attributs doivent être mis à jour, incluez-les ici
      if @reservation.update(reservation_update_params)
        render json: @reservation
      else
        render json: @reservation.errors, status: :unprocessable_entity
      end
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
      workout = @reservation.workout
      unless @reservation.user_id == current_user.id || workout.host_id == current_user.id
        render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
      end
    end

    def authorize_update
      if current_user == @reservation.workout.host
          @reservation_updatable_attributes = [ "status" ]
          @allow_status_update = [ :accepted, :host_cancelled, :refused ]
      elsif current_user == @reservation.user
          @reservation_updatable_attributes = [ "quantity", "status" ]
          @allow_status_update = [ :user_cancelled ]
      else
          render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
      end
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      params.require(:reservation).permit(:workout_id, :quantity)
    end

    def reservation_update_params
      params.require(:reservation).permit(@reservation_updatable_attributes)
    end
end
