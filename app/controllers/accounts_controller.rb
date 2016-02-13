require 'net/http/post/multipart'
class AccountsController < ApplicationController
  before_action :get_token
  before_action :find_account, only: [:conversation, :edit, :update, :share]

  def index
    # Get all accounts
    @accounts = Account.all(params: {search: params[:search]})
  end


  def show
    # Get the acount info and conversation based on id given
    @account = Account.find(params[:id])
    @users = User.all
  end


  def new
    # Add an account
    @account = Account.new
    @users = User.all
  end


  def edit
    # Edit an account
    @account = Account.find(params[:id])
    @addresses = @account.addresses
    @contacts = @account.contacts
    @users = User.all
  end


  def create
    puts "RECEIVED PARAMS = #{account_params}"
    # Create new account
    if params.has_key?(:save)
      #@account = Account.new account_params
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      params[:account][:addresses_attributes] = params[:account][:addresses_attributes]
      @account = Account.new(request: :create, account: account_params)

      if @account.save
        if params.has_key?(:avatar)
          puts "sending avatar..."
          url = URI.parse("#{ENV.fetch("ORCHARD_API_HOST")}/accounts/#{@account.id}")
          #req = Net::HTTP::Put::Multipart.new url.path,  account: { :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")}
          req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")
          req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
          #req.add_field("Content-Type", "application/json")
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end
        end
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'
      end
    end

    redirect_to accounts_path
  end


  def update
    # Update account
    if params.has_key?(:save)
      params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      #params[:account][:addresses_attributes] = params[:account][:addresses_attributes].values
      if @account.update_attributes(name: @account.name, account: account_params)
        flash[:success] = 'Account has been edited successfully'
      else
        flash[:danger] = 'Oops! Unable to edit the account'
      end
    end
    redirect_to account_path(params[:id])
  end


  def schedule_meeting
    flash[:success] = 'Your meeting has been successfully scheduled'
    redirect_to accounts_conversation_path(id)
  end


  def add_note
    c_id = Account.find(conversation_item_params[:account_id]).conversation.id

    ci = ConversationItem.create(conversation_item: {title: conversation_item_params[:title], body: conversation_item_params[:body]}, conversation_id: c_id, type: conversation_item_params[:type])
    if ci
      flash[:success] = 'Your note has been added to the conversation'
    else
      flash[:danger] = 'Oops! Unable to add note'
    end

    redirect_to account_path(conversation_item_params[:account_id])
  end


  def send_email
    c_id = Account.find(conversation_item_params[:account_id]).conversation.id
    ci = ConversationItem.create(conversation_item: {title: conversation_item_params[:title], body: conversation_item_params[:body]}, conversation_id: c_id, type: "email")
    if ci
      flash[:success] = 'Your email has been successfully sent'
    else
      flash[:danger] = 'Oops! Looks like there was a problem sending your email'
    end
    redirect_to account_path(conversation_item_params[:account_id])
  end


  def share
    params[:account][:user_account_sharings] = params[:account][:user_account_sharings].values
    @account.user_account_sharings = params[:account][:user_account_sharings]
    if @account.save
      flash[:success] = 'Shared users updated successfully'
    else
      flash[:danger] = 'Oops! Unable updated the shared users'
    end
    redirect_to account_path(params[:id])
  end
  


  private


  def get_token
    #set gloal var for token to be used in model, hack for now
    $user_token = session[:token]
  end


  def account_params
    params.require(:account).permit(
      :name, :status_id, :assign_to, :shared_with, :about, :quick_facts, :avatar,
      addresses_attributes: [:id, :name, :street_address, :postcode, :city, :region, :country, :_destroy],
      contacts_attributes: [:id, :type, :name, :value, :_destroy]
    )
  end


  def conversation_item_params
    params.require(:conversation_item).permit(:account_id, :type, :title, :body)
  end
  
  def shared_account_params
    params.require(:account).permit(
      user_account_sharings: [:id, :permission, :_destroy]
    )
  end
  
  
  def find_account
    @account = Account.find(params[:id])
  end

end
