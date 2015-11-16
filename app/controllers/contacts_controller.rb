class ContactsController < ApplicationController

  def create
    @account = Account.find(params[:account_id])
    @account.update_attributes(account: {contacts_attributes: [contact_params]})
    redirect_to account_path(@account)
  end

  private
  def contact_params
    params.require(:contact).permit(:type, :name, :value)
  end
end
