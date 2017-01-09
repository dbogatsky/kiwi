Rails.application.routes.draw do
  namespace :admin do
    resources :companies do
      resources :users do
        match :change_password, via: [:get, :patch]
      end

      resources :settings do
        collection do
          patch :update_settings
          patch :add_and_update_property
          patch :add_and_update_asset
          delete :delete_property
          delete :delete_asset
        end
      end
    end
  end

  post '/login', to: 'login#login'
  get '/login', to: 'login#index', as: :user_login

  get '/login/destroy', to: 'login#destroy', as: :user_logout
  get '/login/forgot', to: 'login#forgot', as: :login_forgot
  post '/login/recover', to: 'login#recover', as: :login_recover
  match '/login/:id/change_password', to: 'login#change_password', as: :login_change_password, via: [:get, :patch]

  get '/login/superadmin', to: 'login#superadmin', as: :login_superadmin
  post '/login/superadmin_auth', to: 'login#superadmin_auth', as: :login_superadmin_auth

  match '/dashboard', to: 'dashboard#index', as: :dashboard, via: [:get]

  resource :profile, only: [:show, :update]
  resource :preference, only: [:show, :update]
  get '/preference/integration_office365', to: 'preferences#integration_office365', as: :preference_integration_office365

  get '/accounts/address_mapping', to:'accounts#address_mapping', as: :account_address_mapping
  match  '/accounts/import', to:'accounts#import', as: :account_import, via: [:get, :post]
  get  '/accounts/export', to:'accounts#export', as: :account_export
  get  '/accounts/csv_template', to: 'accounts#csv_template', as: :accounts_csv_template
  get  '/accounts/batch', to:'accounts#batch', as: :account_batch
  post '/accounts/batch_notes', to:'accounts#batch_notes', as: :account_batch_notes
  match '/accounts/add_account_properties', to:'accounts#add_account_properties', as: :account_add_account_properties, via: [:get, :post]
  match '/accounts/import_assets', to:'accounts#import_assets', as: :account_import_assets, via: [:get, :post]
  get  '/accounts/properties_csv_template', to: 'accounts#properties_csv_template', as: :accounts_properties_csv_template
  get  '/accounts/assets_csv_template', to: 'accounts#assets_csv_template', as: :accounts_assets_csv_template
  get  '/accounts/notes_csv_template', to: 'accounts#notes_csv_template', as: :accounts_notes_csv_template
  resources :accounts do
    member do
      patch  :update_note
      patch  :update_reminder
      patch  :update_email
      patch  :update_meeting
      patch  :delete_account_attachment
      patch  :update_quote
      delete :delete_reminder
      delete :delete_note
      delete :delete_email
      get    :delete_meeting
      delete :delete_future_meeting
      delete :delete_quote
      get    :search
      get    :get_users_list # get '/accounts/:id/get_users_list', to: 'accounts#get_users_list'
      get    :load_more_conversation_item
      patch  :update_account_contacts
      get    :updated_account
      patch  :add_related_to_account
      get    :contacts_by_name
    end
    collection do
      get :check_account_duplication
      post :add_conversation_attachment
      patch :get_or_delete_conversation_attachment
    end
    resources :contacts, only: [:edit, :create, :update, :destroy]
    resources :addresses, only: [:edit, :create, :update, :destroy]
  end
  resources :company_entities
  resources :users
  resources :notifications, only: [:index, :update]

  get '/notifications/conversation_detail', to: 'notifications#conversation_detail', as: :notifications_conversation_detail
  get '/n/:id', to: 'notifications#show'
  match '/users/:id/update_time_zone', to: 'users#update_time_zone', as: :users_update_time_zone, via: [:patch]
  get  '/users/:id/not_update_time_zone', to: 'users#not_update_time_zone', as: :users_not_update_time_zone
  post '/accounts/schedule_meeting', to: 'accounts#schedule_meeting', as: :account_schedule_meeting
  post '/accounts/check_in', to: 'accounts#check_in', as: :account_check_in
  post '/accounts/check_out', to: 'accounts#check_out', as: :account_check_out
  post '/accounts/jump_in', to: 'accounts#jump_in', as: :account_jump_in
  post '/accounts/:id/add_note', to: 'accounts#add_note', as: :account_add_note
  post '/accounts/:id/add_asset', to: 'accounts#add_asset', as: :account_add_asset
  put  '/update_asset', to: 'accounts#update_asset', as: :account_update_asset
  post '/accounts/add_quote', to:'accounts#add_quote', as: :account_add_quote
  post '/accounts/add_reminder', to: 'accounts#add_reminder', as: :account_add_reminder
  post '/accounts/:id/send_email', to: 'accounts#send_email', as: :account_send_email
  post '/accounts/:id/share', to: 'accounts#share', as: :account_share
  post '/accounts/:id/account_attachment',to: "accounts#account_attachment", as: :account_attachment
  get  '/accounts/:id/get_account_list_by_scrolling', to: 'accounts#get_account_list_by_scrolling', as: :account_get_account_list_by_scrolling

  match '/schedule', to: 'schedule#index', as: :schedule, via: [:get]
  get   '/schedule/get_notifiable_users', to: 'schedule#get_notifiable_users', as: :schedule_get_notifiable_users
  patch '/schedule/sort_regular_visits', to: 'schedule#sort_regular_visits', as: :schedule_sort_regular_visits
  get   '/schedule/calendar_event', to: 'schedule#calendar_event', as: :schedule_calendar_event
  get   '/schedule/get_meeting', to: 'schedule#get_meeting', as: :schedule_get_meeting
  get   '/schedule/get_events', to: 'schedule#get_events', as: :schedule_get_events
  get   '/schedule/regular_visits', to: 'schedule#regular_visits', as: :schedule_regular_vists
  get   '/schedule/get_account_list_by_scrolling', to: 'schedule#get_account_list_by_scrolling', as: :schedule_get_account_list_by_scrolling
  match '/media', to: 'media#index', as: :media, via: [:get]
  get   '/schedule/get_account_address', to: 'schedule#get_account_address', as: :schedule_get_account_address
  # get   '/schedule/search_account', to: 'schedule#search_account', as: :schedule_search_account
  post '/media/create_folder', to: 'media#create_folder', as: :create_folder
  post '/media/show', to: 'media#show', as: :show
  get  '/media/show_large_image', to: 'media#show_large_image', as: :show_large_image
  post '/media/save_folder', to: 'media#save_folder', as: :save_folder
  post '/media/destroy', to: 'media#destroy', as: :destroy
  post '/media/destroy_multiple', to: 'media#destroy_multiple', as: :destroy_multiple

  post '/media/upload_file', to: 'media#upload_file', as: :upload_file
  post '/media/email_file', to: 'media#email_file', as: :email_file
  get '/media/download_file/:url/:name', to: 'media#download_file', as: :download_file, :constraints => { :url => /.*/ }, via: [:get]
  post '/media/rename_media_file', to: 'media#rename_media_file', as: :rename_media_file

  match '/messages', to: 'messages#index', as: :messages, via: [:get]

  match '/company', to: 'company#index', as: :company, via: [:get]
  get '/company/add', to: 'company#add', as: :company_add
  get '/company/edit/:id', to: 'company#edit', as: :company_edit

  # match '/company/add_entity', to: 'company#add_entity', as: :company_add_entity, via: [:get, :post]
  get '/company/edit_entity/:id', to: 'company#edit_entity', as: :company_edit_entity
  get '/company/:id/display_sub_entites', to: 'company#display_sub_entites', as: :company_display_sub_entites
  post '/company/delete/:id', to: 'company#delete', as: :company_delete

  post '/company/account_status', to: 'company#account_status', as: :account_status
  post '/company/:company_id/company_news', to: 'company#company_news', as: :company_news
  delete '/company/:company_id/delete_news', to: 'company#delete_news', as: :delete_news
  # match '/users', to: 'users#index', as: :users, via: [:get]
  # get '/users/new', to: 'users#new', as: :users_new
  # get '/users/edit/:id', to: 'users#edit', as: :users_edit
  # post '/users/save/', to: 'users#save', as: :users_save
  # post '/users/delete/:id', to: 'users#delete', as: :users_delete

  match '/settings', to: 'settings#index', as: :settings, via: [:get]
  get :get_users, to: 'company#get_users'
  patch '/settings/company_level_setting', to: 'settings#company_level_setting', as: :settings_company_level_setting
  root 'login#index'

  get :meeting_report, to: 'reports#meeting_report'
  get :meeting_report_result, to: 'reports#meeting_report_result'

  get :activity_report, to: 'reports#activity_report'
  get :activity_report_result, to: 'reports#activity_report_result'

  match '(*any)', to: 'errors#routing', via: [:get, :post]
end
