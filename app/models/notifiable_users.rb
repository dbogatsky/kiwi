class NotifiableUsers < OrchardApiModel
  #cached_resource :ttl => 900
  self.prefix = '/api/v1/accounts/:account_id/'
  belongs_to :account
end
