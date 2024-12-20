require 'sidekiq/web'

Rails.application.routes.draw do
  # Interest suggestions
  get 'interests/suggestions', to: 'interests#suggestions'

  # Components preview (development only)
  get 'components', to: 'components#index'
  
  # User registration and management
  resources :users, only: [:new, :create, :edit, :update] do
    collection do
      get 'new_student'
      post 'create_student'
    end
  end
  resource :user, only: [:edit, :update]
  
  resource :session do
    delete :destroy, path: 'logout', as: :logout
  end
  resources :passwords, only: [:new, :create, :edit, :update], param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  get 'dashboard', to: 'home#dashboard', as: :dashboard

  resources :assignments do
    member do
      post :assign_students
      patch :update_status
      patch :update_passage
      get :print
      post :regenerate_image
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
  get '/interests/random', to: 'interests#random'

  # Mount Sidekiq web interface
  mount Sidekiq::Web => '/sidekiq'

  resources :students, only: [:index, :new, :create]
end
