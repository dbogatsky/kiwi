Rails.application.routes.draw do
    post '/login', to: 'login#login'
    get '/login', to: 'login#index', as: :user_login 
    
    get '/login/destroy', to: 'login#destroy', as: :user_logout
    get '/login/forgot', to: 'login#forgot', as: :login_forgot
    post '/login/recover', to:'login#recover', as: :login_recover
    
    match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get] 
    match '/accounts', to: 'accounts#index', as: :accounts, via: [:get] 
    get '/accounts/add', to: 'accounts#add', as: :accounts_add
    get '/accounts/edit/:id', to: 'accounts#edit', as: :accounts_edit
    get '/accounts/:id', to: 'accounts#conversation', as: :accounts_conversation
    
    match '/schedule', to: 'schedule#index', as: :schedule, via: [:get] 
    match '/media', to: 'media#index', as: :media, via: [:get] 
    match '/messages', to: 'messages#index', as: :messages, via: [:get] 
    match '/company', to: 'company#index', as: :company, via: [:get]
    match '/users', to: 'users#index', as: :users, via: [:get] 
    match '/settings', to: 'settings#index', as: :settings, via: [:get] 

    root 'login#index'


    match '*path', to: 'errors#routing', via: [:get, :post]

end
