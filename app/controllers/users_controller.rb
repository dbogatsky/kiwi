require 'net/http/post/multipart'
class UsersController < ApplicationController
	before_action :get_token
  before_action :find_user, only: [:edit, :update]


	def index
		# Get all users
    @all_users = User.all

	end


	def new
		# Add a user
    @user = User.new
		@contact_counter = 2 # Contact index counter


    #get roles (temporary hardcoded)
    @roles = [{id: 1, name: "Admin"},{id: 2, name: "Enitity Admin"},{id: 3, name: "User"}]

	end


  def edit
    # Edit a user

    	@contact_counter = 2 # Check number of existing contacts and up the contact counter.
	end


  def create
    puts "RECEIVED PARAMS = #{user_params}"
    # Create new user

    if params.has_key?(:save)

      params[:user][:contacts_attributes] = params[:user][:contacts_attributes].values
      params[:user][:addresses_attributes] = params[:user][:addresses_attributes]
      @user = User.new(request: :create, user: user_params)

      #params[:account][:contacts_attributes] = params[:account][:contacts_attributes].values
      #params[:account][:addresses_attributes] = params[:account][:addresses_attributes]
      #@account = Account.new(request: :create, account: account_params)

      if @user.save
=begin
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
=end
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'
      end

    end

    redirect_to users_path
  end


  def update
    # Update user


    redirect_to users_path
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
		  $user_token = session[:token]
		end

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :name, :status_id, :assign_to, :shared_with, :about, :quick_facts, :avatar,
        addresses_attributes: [:id, :name, :street_address, :postcode, :city, :region, :country, :_destroy],
        contacts_attributes: [:id, :type, :name, :value, :_destroy]
      )
    end
end
