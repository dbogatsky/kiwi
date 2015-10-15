class OrchardApiAccounts < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    perform_caching false

    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']


    ### Request to accounts api ###
    # get all accounts 
    get :all, "/accounts"

    # get account by id
    get :find, "/accounts/:id"

    # create account
    post :create, "/accounts"    

    # update accounts (single field) by id 
    patch :update, "/accounts/:id"

    # update accounts by id
    put :save, "/accounts/:id"

    # remove accounts by id
    delete :remove, "/accounts/:id"


    # Fake calls for account api
    #post :all, "/account", fake: ->(request) { {  
    #								id: "2",
    #								name:"Canadian Tires", 
	#								acc_status_color: "#0eb057", 
	#								acc_status_name: "Open",
	#								addr_addressable_type: "HQ",
	#								addr_street_address: "2180 Yonge Street",
	#								addr_city: "Toronto",
	#								addr_province: "Ontario",
	#								addr_country: "Canada",
	#								addr_postcode: "M4P 2V8",
	#								contact_contactable_type: "phone",
	#								contact_name: "Telephone",
	#								contact_value: "(123) 456-7890",
	#								} }

end