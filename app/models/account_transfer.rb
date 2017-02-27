class AccountTransfer < OrchardApiModel
  include ActiveResource::Singleton
  self.prefix = "/api/v1/"
  self.collection_name = "account_transfers"




# Allow bulk transfers for all the accounts owned by a user POST /account_transfers body:
# {"account_transfers": [{"from_user_id": "<id>", "to_user_id": "<id>"}]}

#it still supports the old parameters
# Add endpoint to fetch all transfer that can be approved by the current user GET /api/v1/account_transfers/pending_approval



#api/v1/accounts/<account_id>/account_transfer/<account_transfer_id>/approve
#api/v1/accounts/<account_id>/account_transfer/<account_transfer_id>/deny

  def logout
    ActiveResource::Connection.new(OrchardApiModel.site).delete('/api/v1/logout')
  end


end
