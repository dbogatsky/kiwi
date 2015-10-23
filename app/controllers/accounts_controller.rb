class AccountsController < ApplicationController
	before_action :get_token

	def index
		# Get all accounts
		@account_list = Account.accountlist


		# Loop through all the account and apply the proper status info for each one

		# If status id in the account_list does not match in anyone from session, refetch all status via api
		#- account statuses
		#@account_statuses = Account.statuslist
		#session["account"]  ||= {}
		#session["account"]["statuses"] = @account_statuses

	end


	def conversation
		# Get the acount info and conversation based on id given
		@account_info = Account.accountget(params[:id])
		#@conversation = Conversation.whatever_method_by_id(params[:id])

	end


	def add
		# Add an account

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


  def save
    # Save changes from Add/Edit Account page

    if params["account-id"].blank?

      # Create new account
      if Account.accountadd(params["account"]["name"], params["account-status"], params["account"]["address"], params["account"]["contacts"])

        flash[:success] = 'Account has been added successfully'
      else 

        flash[:danger] = 'Oops! Unable to add the account'  # Log in error message  
      end

    else  

      # Edit account
      if Account.accountedit(params["account-id"], params["account"]["name"], params["account-status"], params["account"]["address"], params["account"]["contacts"])

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
		  $user_token = session["user"]["token"]
		end

end
