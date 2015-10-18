class OrchardApiAdminCompanies < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']
    before_request do |name, request|
        request.headers["Authorization"] = 'Token token="'+$user_token+'", app_key="'+APP_CONFIG['api_app_key']+'"'
    end    
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request for company api ###
    # get all company
    get :all, "/company"

    # update company (single field) by id 
    patch :update, "/company/:id"

    # update company by id
    put :save, "/company/:id"

end