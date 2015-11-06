Rails.application.routes.draw do
    post '/login', to: 'login#login'
    get '/login', to: 'login#index', as: :user_login 
    
    get '/login/destroy', to: 'login#destroy', as: :user_logout
    get '/login/forgot', to: 'login#forgot', as: :login_forgot
    post '/login/recover', to:'login#recover', as: :login_recover
	get '/login/superadmin', to: 'login#superadmin', as: :login_superadmin
	post '/login/superadmin_auth', to:'login#superadmin_auth', as: :login_superadmin_auth
    
    match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get] 

   # get '/my_profile', to: 'my_profile#show', as: :my_profile
    resource :profile
   # put '/my_profile', to: 'my_profile#update', as: :my_profile



    match '/accounts', to: 'accounts#index', as: :accounts, via: [:get] 
    get '/accounts/add', to: 'accounts#add', as: :accounts_add
    get '/accounts/edit/:id', to: 'accounts#edit', as: :accounts_edit
    get '/accounts/:id', to: 'accounts#conversation', as: :accounts_conversation
    post '/accounts', to: 'accounts#create', as: :accounts_create
    post '/accounts/:id/schedule_meeting', to:'accounts#schedule_meeting', as: :account_schedule_meeting
    post '/accounts/:id/add_note', to:'accounts#add_note', as: :account_add_note
    post '/accounts/:id/send_email', to:'accounts#send_email', as: :account_send_email
    
    match '/schedule', to: 'schedule#index', as: :schedule, via: [:get] 
    match '/media', to: 'media#index', as: :media, via: [:get] 
    match '/notifications', to: 'notifications#index', as: :notifications, via: [:get]
    match '/messages', to: 'messages#index', as: :messages, via: [:get] 

    match '/company', to: 'company#index', as: :company, via: [:get]
    get '/company/add', to: 'company#add', as: :company_add
    get '/company/edit/:id', to: 'company#edit', as: :company_edit

    get '/company/add_entity', to: 'company#add_entity', as: :company_add_entity
    get '/company/edit_entity/:id', to: 'company#edit_entity', as: :company_edit_entity
    post '/company/delete/:id', to: 'company#delete', as: :company_delete

    post '/company/account_status', to:'company#account_status', as: :account_status

    match '/users', to: 'users#index', as: :users, via: [:get]
    get '/users/add', to: 'users#add', as: :users_add
    get '/users/edit/:id', to: 'users#edit', as: :users_edit
    post '/users/save/', to: 'users#save', as: :users_save
    post '/users/delete/:id', to: 'users#delete', as: :users_delete

    match '/settings', to: 'settings#index', as: :settings, via: [:get] 

    root 'login#index'


    match '*path', to: 'errors#routing', via: [:get, :post]

end
