Rails.application.routes.draw do
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations"
                     }

  # Redirect GET /users to sign up page (handles page refresh after validation errors)
  get "/users", to: redirect("/users/sign_up")

  # API namespace for future Grape API or Rails API endpoints
  namespace :api do
    namespace :v1 do
      # Add your API endpoints here
      # Example: resources :posts, only: [:index, :show, :create, :update, :destroy]
      get "users/check_nickname", to: "users#check_nickname"
      get "users/check_email", to: "users#check_email"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
end
