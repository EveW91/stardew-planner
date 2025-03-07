Rails.application.routes.draw do
  devise_for :users
  root "recipes#index"

  resources :recipes, only: %i[index show] do
    collection do
      get :search
    end

    member do
      get :check_inventory
    end
  end

  resources :save_files, only: %i[new create]
end
