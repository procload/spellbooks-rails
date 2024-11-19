require 'sidekiq/web'

Rails.application.routes.draw do
  # User registration and management
  resources :users, only: [:new, :create]
  resource :user, only: [:edit, :update]
  
  resource :session do
    delete :destroy, path: 'logout', as: :logout
  end
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  resources :assignments do
    member do
      post :assign_students
      get :download_pdf
    end
    
    resources :submissions, only: [:create], controller: 'assignment_submissions'

    resources :questions do
      member do
        post :check_answer
        post :regenerate
      end

      resources :answers, only: [:new, :create, :destroy]
    end
  end

  # Mount Sidekiq web interface
  mount Sidekiq::Web => '/sidekiq'

  # Mount Action Cable server
  mount ActionCable.server => '/cable'

  post 'test_toast', to: 'home#test_toast'
end
