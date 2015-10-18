class OrchardApiConversationItems < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']
    before_request do |name, request|
        request.headers["Authorization"] = 'Token token="'+$user_token+'", app_key="'+APP_CONFIG['api_app_key']+'"'
    end    
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request to conversation items api ###
    # get all conversation items 
    get :all, "/conversations/:conversation_id/items"

    # get conversation items by id
    get :find, "/conversations/:conversation_id/items/:id "

    # create conversation items
    post :create, "/conversations/:conversation_id/items"    

    # update conversation items (single field) by id 
    patch :update, "/conversations/:conversation_id/items/:id"

    # update conversation items by id
    put :save, "/conversations/:conversation_id/items/:id"

    # remove conversation items by id
    delete :remove, "/conversations/:conversation_id/items/:id"


end