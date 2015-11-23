class ContactsController < ApplicationController

  def create
    contact = Contact.create(contact_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  private
  def contact_params
    params.require(:contact).permit(:type, :name, :value)
  end
end
