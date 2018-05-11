Rails.application.routes.draw do
  scope format: true, constraints: { format: /json/ } do
    resource :contribution
    resources :invoices
  end
  
  scope format: true, constraints: { format: /rss/ } do
    scope '/podcast' do
      get '/' => 'podcast#feed', as: :podcast
    end 
  end

  # Let react-router handle this:
  get 'contribution', to: 'home#index'
  get 'invoices', to: 'home#index'

  devise_for :users
  get 'home', to: 'home#index'

  root to: 'home#index'
  
  # Map to localhost:9112 for Lightning Charge, if LIGHTNING_CHARGE_URL isn't set:
  mount LightningChargeProxy.new => '/checkout'
  mount LightningChargeProxy.new => '/static'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
