class AccountTransfer < OrchardApiModel
  include ActiveResource::Singleton
  self.prefix = "/api/v1/"
  self.collection_name = "account_transfers"

  # Allow bulk transfers for all the accounts owned by a user POST /account_transfers body:
  # {"account_transfers": [{"from_user_id": "<id>", "to_user_id": "<id>"}]}
  #it still supports the old parameters
  def self.account_transfer_user_to_user(from_user_id, to_user_id)
    body = "{\"account_transfers\": [{\"from_user_id\": #{from_user_id}, \"to_user_id\": #{to_user_id}}]}"
    response = ActiveResource::Connection.new(OrchardApiModel.site).post('/api/v1/account_transfers', body, OrchardApiModel.headers)
  end

  # Add endpoint to fetch all transfer that can be approved by the current user GET /api/v1/account_transfers/pending_approval
  def self.pending_approval
    response = ActiveResource::Connection.new(OrchardApiModel.site).get('/api/v1/account_transfers/pending_approval', OrchardApiModel.headers)
  end

  #api/v1/accounts/<account_id>/account_transfer/<account_transfer_id>/approve
  def self.approve(account_id, account_transfer_id)
    url = "/api/v1/accounts/#{account_id}/account_transfer/#{account_transfer_id}/approve"
    response = ActiveResource::Connection.new(OrchardApiModel.site).put(url, '', OrchardApiModel.headers)
  end

  #api/v1/accounts/<account_id>/account_transfer/<account_transfer_id>/deny
  def self.deny(account_id, account_transfer_id)
    url = "/api/v1/accounts/#{account_id}/account_transfer/#{account_transfer_id}/deny"
    response = ActiveResource::Connection.new(OrchardApiModel.site).put(url, '', OrchardApiModel.headers)
  end

end
