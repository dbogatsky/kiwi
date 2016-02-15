Rails.application.routes.draw do

    post '/login', to: 'login#login'
    get '/login', to: 'login#index', as: :user_login

    get '/login/destroy', to: 'login#destroy', as: :user_logout
    get '/login/forgot', to: 'login#forgot', as: :login_forgot
    post '/login/recover', to:'login#recover', as: :login_recover
    match '/login/:id/change_password', to: 'login#change_password', as: :login_change_password, via: [:get, :patch]

  	get '/login/superadmin', to: 'login#superadmin', as: :login_superadmin
  	post '/login/superadmin_auth', to:'login#superadmin_auth', as: :login_superadmin_auth

    match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get]

   # get '/my_profile', to: 'my_profile#show', as: :my_profile
    resource :profile
    resources :accounts do
      resources :contacts, only: [:edit, :create, :update, :destroy]
      resources :addresses, only: [:edit, :create, :update, :destroy]
    end
    resources :company_entities
    resources :users

    post '/accounts/:id/schedule_meeting', to:'accounts#schedule_meeting', as: :account_schedule_meeting
    post '/accounts/:id/add_note', to:'accounts#add_note', as: :account_add_note
    post '/accounts/:id/send_email', to:'accounts#send_email', as: :account_send_email
    post '/accounts/:id/share', to:'accounts#share', as: :account_share

    match '/schedule', to: 'schedule#index', as: :schedule, via: [:get]
    match '/media', to: 'media#index', as: :media, via: [:get]

    post '/media/create_folder', to:'media#create_folder', as: :create_folder
    post '/media/show', to:'media#show', as: :show
    get  '/media/show_large_image', to:'media#show_large_image', as: :show_large_image
    post '/media/save_folder', to:'media#save_folder', as: :save_folder
    post '/media/destroy', to:'media#destroy', as: :destroy
    post '/media/destroy_multiple', to:'media#destroy_multiple', as: :destroy_multiple

    post '/media/upload_file', to:'media#upload_file', as: :upload_file
    post '/media/email_file', to:'media#email_file', as: :email_file
    get '/media/download_file/:url/:name', to:'media#download_file', as: :download_file, :constraints => { :url => /.*/}, via: [:get]
	post '/media/rename_media_file', to:'media#rename_media_file', as: :rename_media_file

    match '/notifications', to: 'notifications#index', as: :notifications, via: [:get]
    match '/messages', to: 'messages#index', as: :messages, via: [:get]

    match '/company', to: 'company#index', as: :company, via: [:get]
    get '/company/add', to: 'company#add', as: :company_add
    get '/company/edit/:id', to: 'company#edit', as: :company_edit

    # match '/company/add_entity', to: 'company#add_entity', as: :company_add_entity, via: [:get, :post]
    get '/company/edit_entity/:id', to: 'company#edit_entity', as: :company_edit_entity
    get '/company/:id/display_sub_entites', to: 'company#display_sub_entites', as: :company_display_sub_entites
    post '/company/delete/:id', to: 'company#delete', as: :company_delete

    post '/company/account_status', to:'company#account_status', as: :account_status

    # match '/users', to: 'users#index', as: :users, via: [:get]
    # get '/users/new', to: 'users#new', as: :users_new
    # get '/users/edit/:id', to: 'users#edit', as: :users_edit
    # post '/users/save/', to: 'users#save', as: :users_save
    # post '/users/delete/:id', to: 'users#delete', as: :users_delete

    match '/settings', to: 'settings#index', as: :settings, via: [:get]

    root 'login#index'


    match '*path', to: 'errors#routing', via: [:get, :post]

end
