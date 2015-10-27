class OrchardApiModel < ActiveResource::Base
  self.site = ENV.fetch("ORCHARD_API_HOST")
  self.headers['Authorization'] = 'Token token="secret_tQ9SZmGSr6yY4zacGQPp", app_key="app_LL1zKMy_vLixnHSyyiAB"'
end
