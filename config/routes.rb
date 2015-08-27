Rails.application.routes.draw do
  get 'sip_ip/search'

  root 'records#search'

  get 'examples', to: 'records#examples'
  get 'search', to: 'records#search'
  # post 'search', to: 'records#search'
  get 'sip', to: 'sip_ip#search'
end
