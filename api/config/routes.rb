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

      # マスタデータ
      get "master_data", to: "master_data#show"

      # ランダムな労いメッセージを返す
      resource :greeting, only: [:show], controller: 'greeting'

      # 家事ログ
      resources :logs, only: [:create]

      # 家族関連
      resources :families, only: [] do
        post :invitations, to: "families/invitations#create"
        resources :tasks, only: [:index], controller: "families/tasks"
      end

      namespace :family do
        resources :logs, only: [:index]
      end

      # 招待
      scope :invitations, controller: :invitations do
        get  :verify
        post :complete
      end

      # サインアップ
      scope :signup, controller: :signup do
        post :email
        get  :verify
        post :complete
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"

  # Letter Opener Web (development only)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
