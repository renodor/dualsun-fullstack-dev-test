# frozen_string_literal:true

Rails.application.routes.draw do
  post '/companies/find_or_create', to: 'companies#find_or_create'
  post '/customers/find_or_create', to: 'customers#find_or_create'
  resources :installations, only: :create
  post '/panels/bulk_create', to: 'panels#bulk_create'
end
