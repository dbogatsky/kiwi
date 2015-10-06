class Token < ActiveRestClient::Base
    base_url APP_CONFIG['api_url']   
    request_body_type :json


    # Request for token
    post :create, "/token", defaults: {app_key:APP_CONFIG['api_app_key'], user:{email:"test@example.com", password: "12341234" }}
end

