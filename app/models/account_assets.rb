class AccountAssets < OrchardApiModel
  #cached_resource :ttl => 900

  self.prefix = '/api/v1/accounts/:account_id/'
  self.element_name = "assets"
  belongs_to :account
end
