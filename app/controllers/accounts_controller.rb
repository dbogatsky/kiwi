class AccountsController < ApplicationController
	before_action :get_token

	def index
		# Get all accounts
		@accounts = Account.all


		# Loop through all the account and apply the proper status info for each one

		# If status id in the account_list does not match in anyone from session, refetch all status via api
		#- account statuses
		#@account_statuses = Account.statuslist
		#session["account"]  ||= {}
		#session["account"]["statuses"] = @account_statuses

	end


	def conversation
		# Get the acount info and conversation based on id given
		@account_info = Account.find(params[:id])
		#@conversation = Conversation.whatever_method_by_id(params[:id])

	end


	def new
		# Add an account

    @account_new = new Account

    @contact_counter = 2 # Contact index counter
		
		#get status cached upon login from session
		@account_statuses = session["account"]["statuses"]

	end


  def edit
    # Edit an account
    @account_info = Account.accountget(params[:id])

    @contact_counter = 2 # Check number of existing contacts and up the contact counter.
    
    #get status cached upon login from session
    @account_statuses = session["account"]["statuses"]

  end


  def create
    # Create new account

    account_new.new accounts_params

    if false
      flash[:success] = 'Account has been added successfully'
    else
      flash[:danger] = 'Oops! Unable to add the account'  # Log in error message  
    end

    redirect_to accounts_path
  end

  def update
    # Update account

    account_update.update_attributes accounts_params

    if false
      flash[:success] = 'Account has been edited successfully'
    else
      flash[:danger] = 'Oops! Unable to edit the account'  # Log in error message  
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

end
