Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      get "logged_in", to: "sessions#logged_in"

      # ランダムな労いメッセージを返す
      resource :greeting, only: [:show], controller: 'greeting'

      # 家事ログ
      resources :logs, only: [:create]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
