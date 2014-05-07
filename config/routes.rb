Rails.application.routes.draw do
  root 'home#index'

  resources :resques, only: [ :index, :show ] do
    resource :jobs, only: [ :show ] do
      resources :failed, only: [ :index, :show, :destroy ] do
        member do
          post 'retry'
        end
      end
      member do
        get 'running'
        get 'waiting'
      end
    end
    resources :workers, only: [ :destroy ]
  end
end
