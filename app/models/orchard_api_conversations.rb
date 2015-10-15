class OrchardApiConversations < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request to conversations api ###
    # get all conversations 
    get :all, "/conversations"

    # get conversations by id
    get :find, "/conversations/:id"

end