class AccountTransfer < OrchardApiModel
  include ActiveResource::Singleton
  self.prefix = "/api/v1/"
  self.collection_name = "account_transfers"
end
