class OrchardApiModel < ActiveResource::Base

  cattr_accessor :static_headers
  self.static_headers = headers

  def self.headers
    new_headers = static_headers.clone
    new_headers['Authorization'] = "Token token=\"#{RequestStore.store[:user_token]}\", app_key=\"#{APP_CONFIG['api_app_key']}\""
    new_headers
  end

end
