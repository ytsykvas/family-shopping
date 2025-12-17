Rails.application.routes.draw do
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations"
                     }

  get "/users", to: redirect("/users/sign_up")

  namespace :api do
    namespace :v1 do
      get "users/check_nickname", to: "users#check_nickname"
      get "users/check_email", to: "users#check_email"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check


  resources :friends, only: [ :index ]
  resources :user_searches, only: [ :index ]

  root "home#index"
end
