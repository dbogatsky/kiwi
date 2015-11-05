class OrchardApiModel < ActiveResource::Base
  self.site = ENV.fetch("ORCHARD_API_HOST")
  self.headers['Authorization'] = "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\""
end
