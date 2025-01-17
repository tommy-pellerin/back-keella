class CheckoutController < ApplicationController
  before_action :authenticate_user!, except: [ :refund_payment ]

  def create
    if Rails.env.production?
      @url = "https://front-keella.vercel.app/payment"
    else
      @url = "http://localhost:5173/payment"
    end

    @total = params[:total].to_d
    @user = current_user
    # Generate a unique token
    @sessionToken = SecureRandom.uuid

    @session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      metadata: {
        # user_id: @user_id,
        token: @sessionToken
      },
      line_items: [
        {
          price_data: {
            currency: "eur",
            unit_amount: (@total*100).to_i,
            product_data: {
              name: "Credit à recharger"
            }
          },
          quantity: 1
        }
      ],
      mode: "payment",
      # méthode avec page paiement gébergé par stripe
      success_url: @url + "/success" + "?session_id={CHECKOUT_SESSION_ID}&session_token=#{@sessionToken}",
      cancel_url: @url + "/cancel",
    )
    # Store the session ID in the user's session
    session[:stripe_checkout_session_id] = @session.id
    # store token in user table
    @user.update(session_token: @sessionToken)
    # méthode avec page paiement gébergé par stripe
    render json: { sessionUrl: @session.url }, status: :ok
  end

  def success
    # Retrieve session_id from checkout_params
    session_id = checkout_params[:session_id]
    # Retrieve the session from Stripe using the session_id
    @session = Stripe::Checkout::Session.retrieve(session_id)
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    @user = current_user
    # Check if the token in the URL matches the token stored with the user
    # Retrieve session_token from checkout_params
    session_token = checkout_params[:session_token]
    if session_token == @user.session_token
      payment_proceed(@user, @payment_intent)
    else
      # If the tokens do not match, redirect the user
      render json: { error: "Access refusé car le paiement a déjà été traité" }, status: :forbidden
    end
  end


  def refund_payment
    session_id = params[:session_id] # Ou utilisez params[:payment_intent_id] si vous avez l'ID de l'intention de paiement
    session = Stripe::Checkout::Session.retrieve(session_id)
    payment_intent_id = session.payment_intent

    # Récupère les détails de l'intention de paiement pour obtenir le montant et l'email du client
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

    # Déterminez le montant du remboursement ici. Pour un remboursement complet, utilisez payment_intent.amount_received
    refund_amount = payment_intent.amount_received # ou un montant partiel spécifique

    # Déduire les frais de services selon si la carte est international ou européen ou britanique
    # total_refund_amount = (refund_amount - 0.25*100 - (refund_amount*3.25/100).round).round  # only for international carte (used by stripe)
    # Créez le remboursement
    # Attention au frais de service de STRIPE qui doit etre calculé à la main 1.5% + 0.25€
    refund = Stripe::Refund.create({
      payment_intent: payment_intent_id,
      amount: refund_amount
    })
    # Répond avec les détails du remboursement
    render json: { status: "success", refund: refund }
  rescue Stripe::StripeError => e
    render json: { status: "error", message: e.message }, status: :bad_request
  end

  private

  def payment_proceed(user, payment_intent)
    @user = user
    @payment_intent = payment_intent
    @user.update(credit: @user.credit + @payment_intent.amount_received.to_f/100, session_token: nil)
    UserMailer.payment_confirmation_email(@user, @payment_intent).deliver_now

    # Send a success response
    render json: {
      message: "Paiement réussi et confirmé. Merci pour votre achat.",
      credit_amount: @payment_intent.amount_received.to_f / 100,
      payment_intent_status: @payment_intent.status
    }, status: :ok
  end

  # Only allow a list of trusted parameters through.
  def checkout_params
    params.require(:checkout).permit(:session_id, :session_token)
  end
end
