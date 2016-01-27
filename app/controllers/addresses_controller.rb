class AddressesController < ApplicationController
  def edit
    @account = Account.find(params[:account_id])
    @address = address.find( params[:id], params: {account_id: params[:account_id]})
  end

  def create
    @address = Address.new(address_params)
    @account = Account.find(params[:account_id])
    
    respond_to do |format|
      if @address.save
        @status = "ok"
        @notification_message = "Address created with success."
        format.html { redirect_to @address.account, notice: 'Address was successfully created.' }
        format.js   { }
        format.json { render :show, status: :created, location: @address }
      else
        @notification_message = "Errors in create contact"
        format.html { render :new }
        format.js { }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
    #address = Address.create(address_params.merge({account_id: params[:account_id]}))
    #redirect_to account_path(params[:account_id])
  end

  def update
    @address = Address.find( params[:id], params: {account_id: params[:account_id]})
    @address.update_attributes(address_params.merge({account_id: params[:account_id]}))
    redirect_to account_path(params[:account_id])
  end

  def destroy
    @address = Address.find( params[:id], params: {account_id: params[:account_id]})
    respond_to do |format|
      if Address.delete(params[:id], account_id: params[:account_id])
        @status = "ok"
        @notification_message = ""
        format.js { }
        format.html { redirect_to account_path(params[:account_id]) }
      else
        @notification_message = ""
        format.js { }
      end
    end
    #Address.delete(params[:id], account_id: params[:account_id])
    #redirect_to account_path(params[:account_id])
  end

  private

  def address_params
    params.require(:address).permit(:name, :street_address, :postcode, :city, :region, :country, :account_id)
  end

  def prefix_options
    { :account_id => account_id }
  end
end

