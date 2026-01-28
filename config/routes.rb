Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  resources :items

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"
end
