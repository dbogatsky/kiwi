class OrchardApiAccounts < ActiveRestClient::Base
	
	#api details
    base_url APP_CONFIG['api_url']   
    request_body_type :json
    
    #enable to true for debugging
    verbose APP_CONFIG['api_verbose']

    # Request for token
    post :all, "/account", fake: ->(request) { {  
    								id: "2",
    								name:"Canadian Tires", 
									acc_status_color: "#0eb057", 
									acc_status_name: "Open",
									addr_addressable_type: "HQ",
									addr_street_address: "2180 Yonge Street",
									addr_city: "Toronto",
									addr_province: "Ontario",
									addr_country: "Canada",
									addr_postcode: "M4P 2V8",
									contact_contactable_type: "phone",
									contact_name: "Telephone",
									contact_value: "(123) 456-7890",
									} }

end

