Rails.application.routes.draw do
  mount ApiRoot => "/"
  mount GrapeSwaggerRails::Engine => "/api/docs"
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations"
                     }

  get "/users", to: redirect("/users/sign_up")


  get "up" => "rails/health#show", as: :rails_health_check


  resources :friends, only: [ :index, :destroy ]
  resources :user_searches, only: [ :index ]
  resources :friendship_requests, only: [ :index, :create, :update, :destroy ]

  root "home#index"
end
