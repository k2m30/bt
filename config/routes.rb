Rails.application.routes.draw do
  resources :records
  root 'records#index'

  get 'import', to: 'records#import'
  get 'search', to: 'records#search'
  post 'search', to: 'records#search'
end
