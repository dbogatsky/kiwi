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
    post '/accounts/:id/schedule_meeting', to:'accounts#schedule_meeting', as: :account_schedule_meeting
    post '/accounts/:id/add_note', to:'accounts#add_note', as: :account_add_note
    post '/accounts/:id/send_email', to:'accounts#send_email', as: :account_send_email
    
    match '/schedule', to: 'schedule#index', as: :schedule, via: [:get] 
    match '/media', to: 'media#index', as: :media, via: [:get] 
    match '/messages', to: 'messages#index', as: :messages, via: [:get] 

    match '/company', to: 'company#index', as: :company, via: [:get]
    get '/company/show/:id', to: 'company#show', as: :company_show
    get '/company/add', to: 'company#add', as: :company_add
    get '/company/edit/:id', to: 'company#edit', as: :company_edit
    post '/company/delete/:id', to: 'company#delete', as: :company_delete

    match '/users', to: 'users#index', as: :users, via: [:get] 
    match '/settings', to: 'settings#index', as: :settings, via: [:get] 

    root 'login#index'


    match '*path', to: 'errors#routing', via: [:get, :post]

end
