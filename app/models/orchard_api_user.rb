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

    # Request for token
    get :find, "/users/:id" 
    
end

