Rails.application.routes.draw do
  post '/login', to: 'login#login'
  get '/login', to: 'login#index', as: :user_login 
  match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get] 
  root 'login#index'


  match '*path', to: 'errors#routing', via: [:get, :post]

end
