Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :products, only: %i(show index)
  resources :carts, only: %i(index)
  resources :orders, only: %i(show create)
  resources :payments, only: %i(new create)
  post '/payments/cancel', to: 'payments#cancel'
  post '/payments/provider_notify', to: 'payments#provider_notify'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
