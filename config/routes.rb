Rails.application.routes.draw do
  devise_for :users
  get 'hello_world', to: 'hello_world#index'

  root to: 'hello_world#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
