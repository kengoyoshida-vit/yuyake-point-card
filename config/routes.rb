Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :liff do
    get "entry", to: "entry#show"
    get "checkin", to: "checkin#show"
    resource :session, only: [ :create ]
    resource :mypage, only: [ :show ], controller: "mypage"
    resource :profile, only: [ :show, :edit, :update ] do
      post :skip
    end
    resources :events, only: [] do
      resource :checkin, only: [ :new, :create ]
    end
  end

  # Defines the root path route ("/")
  root "liff/entry#show"
end
