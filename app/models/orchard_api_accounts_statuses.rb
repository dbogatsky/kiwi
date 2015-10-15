class OrchardApiAccountsStatuses < ActiveRestClient::Base
    before_request do |name, request|
    	request.headers["Authorization"] = 'Token token="'+$user_token+'", app_key="'+APP_CONFIG['api_app_key']+'"'
	end
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    perform_caching false
    

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request to accounts_statuses api ###
    # get all  accounts statuses 
    get :all, "/account_statuses"

    # get accounts status by id
    get :find, "/account_statuses/:id"

    # create accounts status
    post :create, "/account_statuses"    

    # update accounts status (single field) by id 
    patch :update, "/account_statuses/:id"

    # update accounts status by id
    put :save, "/account_statuses/:id"

end