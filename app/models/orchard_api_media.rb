class OrchardApiMedia < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    
    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']

    ### Request for media api ###
    # get all media
    get :all, "/media"
    
end

