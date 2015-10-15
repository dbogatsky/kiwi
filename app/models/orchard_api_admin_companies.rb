class OrchardApiAdminCompanies < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    # Request for company api
    # get all company
    get :all, "/company"

    # update company (single field) by id 
    patch :update, "/company/:id"

    # update company by id
    put :save, "/company/:id"


    # Request for company_entities api
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