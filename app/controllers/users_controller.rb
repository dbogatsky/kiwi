class UsersController < ApplicationController
	before_action :get_token



	def index
		# Get all users
    @all_users = User.all

	end


	def add
		# Add a user

		@contact_counter = 2 # Contact index counter


    #get roles (temporary hardcoded)
    @roles = [{id: 1, name: "sales"},{id: 2, name: "manager"}]

	end


  def edit
    # Edit a user

    	@contact_counter = 2 # Check number of existing contacts and up the contact counter.
	end


  def save
    # Save changes from Add/Edit User page

    if params["user-id"].blank?

      # Create new user
      if User.useradd(params["user-email"])

        flash[:success] = 'User has been added successfully'
      else 

        flash[:danger] = 'Oops! Unable to add the user'  # Log in error message  
      end

    else 

      # Edit user
      if User.useredit(params["user-id"], params["user-email"])

        flash[:success] = 'User has been edited successfully'
      else 

        flash[:danger] = 'Oops! Unable to edit the user'  # Log in error message  
      end

    end

    redirect_to users_path
  end



	private

		def get_token
		  #set gloal var for token to be used in model, hack for now
		  $user_token = session["user_token"]
		end

end
