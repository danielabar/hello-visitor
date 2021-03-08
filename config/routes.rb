Rails.application.routes.draw do
  resources :visits, only: %i[index show create]
end
