Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  resources :items do
    member do
      post :regenerate_ai
    end
    collection do
      post :suggest_metadata
    end
    resources :reviews, only: [ :create, :edit, :update, :destroy ]
  end

  get "search/items", to: "searches#items"
  get "write_review", to: "reviews#start", as: :new_review_wizard

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"
end
