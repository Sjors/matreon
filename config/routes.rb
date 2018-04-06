Rails.application.routes.draw do
  # Let react-router handle this:
  get 'contribution', to: 'home#index'

  devise_for :users
  get 'home', to: 'home#index'

  root to: 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
