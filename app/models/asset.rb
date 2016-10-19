class Asset < OrchardApiModel
  #cached_resource
  self.prefix = "/api/v1/accounts/:account_id/"
end
