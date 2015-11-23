class ContactsController < ApplicationController
  def edit
    @account = Account.find(params[:account_id])
    @contact = Contact.find( params[:id], params: {account_id: params[:account_id]})
  end

  def create
    contact = Contact.create(contact_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  def update
    @contact = Contact.find( params[:id], params: {account_id: params[:account_id]})
    @contact.update_attributes(contact_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  def destroy
    Contact.delete(params[:id], account_id: params[:account_id])
    redirect_to account_path(params[:account_id])
  end

  private
  def contact_params
    params.require(:contact).permit(:type, :name, :value)
  end
end
