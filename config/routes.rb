Rails.application.routes.draw do
  post '/login', to: 'login#login'
  get '/login', to: 'login#index', as: :user_login 
  get '/login/destroy', to: 'login#destroy', as: :user_logout
  match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get] 
  root 'login#index'


  match '*path', to: 'errors#routing', via: [:get, :post]

end
