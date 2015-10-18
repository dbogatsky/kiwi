class OrchardApiAdminCompanyEntities < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']
    before_request do |name, request|
        request.headers["Authorization"] = 'Token token="'+$user_token+'", app_key="'+APP_CONFIG['api_app_key']+'"'
    end    
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request for company_entities api ###
    # get all company entities
    get :all, "/company_entities"

    # get company entities by id
    get :find, "/company_entities/:id"

    # create company entities
    post :create, "/company_entities" 

    # update company entities (single field) by id 
    patch :update, "/company_entities/:id"

    # update company entities by id
    put :save, "/company_entities/:id"

    # update company entities by id
    delete :remove, "/company_entities/:id"

end