Rails.application.routes.draw do
  post "recipes/:id/add_to_shopping_list", to: "add_to_shopping_list#create", as: :add_to_shopping_list_recipe
  mount ApiRoot => "/"
  mount GrapeSwaggerRails::Engine => "/api/docs"
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations"
                     }

  get "/users", to: redirect("/users/sign_up")
  resources :users, only: [ :show ]


  get "up" => "rails/health#show", as: :rails_health_check



  resources :friends, only: [ :index, :destroy ]
  resources :user_searches, only: [ :index ]
  resources :friendship_requests, only: [ :index, :create, :update, :destroy ]
  resources :shopping_lists, except: [ :new, :edit ] do
    resources :shopping_list_items, only: [ :create, :update, :destroy ]
  end
  resources :shopping_list_memberships, only: [ :destroy ]
  resources :shopping_list_invitations, only: [ :create, :update, :destroy ]
  resources :wishlist_items, only: [ :index, :show, :create, :update, :destroy ] do
    post :book, on: :member
    delete :unbook, on: :member
  end

  resources :recipes

  root "home#index"
end
