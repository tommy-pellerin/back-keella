class CheckoutController < ApplicationController
  # before_action :authenticate_user!

  def create
    @url = "http://localhost:5173/payment"
    puts "#"*50
    puts "Je suis dans create de checkout_controller.rb"
    puts params
    puts "#"*50
    @total = params[:total].to_d
    # @user_id = params[:user_id]
    # @user = User.find(params[:user_id])

    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      # metadata: {
      #   user_id: @user_id,
      #   token: @token
      # },
      line_items: [
        {
          price_data: {
            currency: 'eur',
            unit_amount: (@total*100).to_i,
            product_data: {
              name: 'Rails Stripe Checkout',
            },
          },
          quantity: 1
        },
      ],
      mode: 'payment',
      # méthode avec page paiement gébergé par stripe
      success_url: @url + '/success' + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: @url + '/cancel',
    )
    # Store the session ID in the user's session
    session[:stripe_checkout_session_id] = @session.id

    # méthode avec page paiement gébergé par stripe
    render json: { sessionUrl: @session.url }, status: :ok
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    puts "#"*50
    puts "success payment"
  end

end
