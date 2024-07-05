Rails.application.routes.draw do
  scope "/checkout" do
    post "create", to: "checkout#create", as: "checkout_create"
    patch 'success', to: 'checkout#success', as: 'checkout_success'
    post "refund_payment", to: "checkout#refund_payment", as: "checkout_refund_payment"
  end
  resources :ratings
  resources :categories
  resources :reservations
  resources :workouts
  
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  devise_scope :user do
    delete "sign_out", to: "users/sessions#destroy"
  end
  resources :users, only: [ :index, :show, :destroy ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
