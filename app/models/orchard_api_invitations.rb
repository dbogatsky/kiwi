class OrchardApiInvitations < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    
    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']

    ### Request for invitations api ###
    # save invitations 
    put :save, "/invitations"
    
end

