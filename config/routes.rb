Rails.application.routes.draw do
  root 'records#search'

  get 'import', to: 'records#import'
  get 'search', to: 'records#search'
  post 'search', to: 'records#search'
end
