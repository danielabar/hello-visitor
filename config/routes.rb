Rails.application.routes.draw do
  devise_for :users
  root to: 'visits#index'

  resources :visits, only: %i[index show create]
  resources :search, only: %i[index]
end
