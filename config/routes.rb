Rails.application.routes.draw do
  root 'records#search'

  get 'examples', to: 'records#examples'
  get 'search', to: 'records#search'
  post 'search', to: 'records#search'
end
