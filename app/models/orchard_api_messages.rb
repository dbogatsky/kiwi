class OrchardApiMessages < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    
    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']

    # Request for token
    post :create, "/token", defaults: {app_key:APP_CONFIG['api_app_key']}
    
end

