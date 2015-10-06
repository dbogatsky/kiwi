class Token < ActiveRestClient::Base
    base_url APP_CONFIG['api_url']   
    request_body_type :json

    # Request for token
    post :token, "/token", defaults: {app_key:APP_CONFIG['api_app_key']}

end
