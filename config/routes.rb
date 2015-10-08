Rails.application.routes.draw do
  post '/login', to: 'login#login'
  get '/login', to: 'login#index', as: :user_login 
  get '/login/destroy', to: 'login#destroy', as: :user_logout
  match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get] 
  match '/accounts', to: 'accounts#index', as: :accounts, via: [:get] 
  get '/accounts/:id', to: 'accounts#conversation', as: 'accounts_conversation'
  match '/schedule', to: 'schedule#index', as: :schedule, via: [:get] 
  match '/media', to: 'media#index', as: :media, via: [:get] 

  root 'login#index'


  match '*path', to: 'errors#routing', via: [:get, :post]

end
