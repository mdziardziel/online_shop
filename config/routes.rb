Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :products, only: %i(show index)
  post 'cart/add_product', to: 'carts#add_product'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
