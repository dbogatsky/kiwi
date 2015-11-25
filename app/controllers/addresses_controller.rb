class AddressesController < ApplicationController
  def edit
    @account = Account.find(params[:account_id])
    @address = address.find( params[:id], params: {account_id: params[:account_id]})
  end

  def create
    address = Address.create(address_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  def update
    @address = Address.find( params[:id], params: {account_id: params[:account_id]})
    @address.update_attributes(address_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  def destroy
    Address.delete(params[:id], account_id: params[:account_id])
    redirect_to account_path(params[:account_id])
  end

  private
  def address_params
    params.require(:address).permit(:name, :street_address, :postcode, :city, :region, :country)
  end
end

