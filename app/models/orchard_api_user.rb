class OrchardApiUser < ActiveRestClient::Base
	#api details
    base_url APP_CONFIG['api_url'] 
    before_request do |name, request|
    	request.headers["Authorization"] = 'Token token="'+$user_token+'", app_key="'+APP_CONFIG['api_app_key']+'"'
	end
    request_body_type :json
    perform_caching false
    
    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request to users api ###
    # get all users
    get :all, "/users"

    # get user by id 
    get :find, "/users/:id"

    # create new user 
    post :create, "/users"

    # update user (single field) by id 
    patch :update, "/users/:id"

    # update user by id
    put :save, "/users/:id"

end