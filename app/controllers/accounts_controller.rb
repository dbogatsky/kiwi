class AccountsController < ApplicationController
  before_action :get_token
  before_action :find_account, only: [:conversation, :edit, :update]

  def index
    # Get all accounts
    @accounts = Account.all(params: {search: params[:search]})

    @account_statuses = get_hashed_account_statuses

  end


  def show
    # Get the acount info and conversation based on id given
    @account = Account.find(params[:id])

    #retrieve conversation - assuming at the moment that the account id = conversation id
    @conversation = Conversations.find(params[:id])
  end


  def new
    # Add an account
    @account = Account.new

    @contact_counter = 2 # Contact index counter

    #get status cached upon login from session
    @account_statuses = session["account"]["statuses"]

  end


  def edit
    # Edit an account
    #@account = Account.find(params[:id])

    @contact_counter = 2 # Check number of existing contacts and up the contact counter.

    #get status cached upon login from session
    @account_statuses = session["account"]["statuses"]

  end


  def create
    # Create new account

    if params.has_key?(:save)

      @account = Account.new accounts_params

      if @account.save
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'  # Log in error message  
      end

    end 

    redirect_to accounts_path
  end

  def update
    # Update account

    if params.has_key?(:save)

      if @account.update_attributes(accounts_params)
        flash[:success] = 'Account has been edited successfully'
      else
        flash[:danger] = 'Oops! Unable to edit the account'  # Log in error message  
      end

    end

    redirect_to accounts_path
  end



  def schedule_meeting
    flash[:success] = 'Your meeting has been successfully scheduled'
    redirect_to accounts_conversation_path(id)
  end 

  def add_note
    flash[:success] = 'Your note has been added to the conversation'
    redirect_to accounts_conversation_path(id)
  end

  def send_email
    flash[:success] = 'Your email has been successfully sent'
    redirect_to accounts_conversation_path(id)
  end


  private

  def get_token
    #set gloal var for token to be used in model, hack for now
    $user_token = session[:token]
  end

  def accounts_params
    params.require(:account).permit(:name, :status_id)
  end

  def find_account
    @account = Account.find(params[:id])
  end

  def get_hashed_account_statuses

    account_statuses = Hash.new
    session["account"]["statuses"].each do | account_status |
      account_statuses[account_status["id"]] = account_status
    end

    account_statuses
  end

end
