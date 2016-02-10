class ContactsController < ApplicationController
  def edit
    @account = Account.find(params[:account_id])
    @contact = Contact.find( params[:id], params: {account_id: params[:account_id]})
  end

  #def create
  #  contact = Contact.create(contact_params.merge({account_id: params[:account_id]}))
  #  redirect_to account_path(params[:account_id])
  #end
  def create
    @contact = Contact.new(contact_params)
    @account = Account.find(params[:account_id])

    respond_to do |format|
      if @contact.save
        @status = "ok"
        @notification_message = "Contact created with success."
        format.html { redirect_to @contact.account, notice: 'Contact was successfully created.' }
        format.js   { }
        format.json { render :show, status: :created, location: @contact }
      else
        @notification_message = "Errors in create contact"
        format.html { render :new }
        format.js { }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @contact = Contact.find( params[:id], params: {account_id: params[:account_id]})
    respond_to do |format|
      if @contact.update_attributes(contact_params.merge({account_id: params[:account_id]}))
        format.js { }
      else
        #TODO: ugly way to show error messages in json. Fix it!
        format.json { render :json => { :success => false, :status => "error", :msg => @contact.errors.messages[:value].first.to_s } }
        #puts "update ko. #{@contact.errors.messages}"
      end
    end
    #redirect_to account_path(params[:account_id])
  end

  def destroy
    #@contact = Account.find(params[:account_id]).contacts.find(params[:id])
    @contact = Contact.find( params[:id], params: {account_id: params[:account_id]})
    respond_to do |format|
      if Contact.delete(params[:id], account_id: params[:account_id])
        @status = "ok"
        @notification_message = ""
        format.js { }
        format.html { redirect_to account_path(params[:account_id]) }
      else
        @notification_message = ""
        format.js { }
      end
    end

    #Contact.delete(params[:id], account_id: params[:account_id])
    #redirect_to account_path(params[:account_id])
  end

  private
  def contact_params
    params.require(:contact).permit(:type, :name, :value, :account_id)
  end

  def prefix_options
    { :account_id => account_id }
  end
end
