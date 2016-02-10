require 'net/http/post/multipart'
class UsersController < ApplicationController
	before_action :get_token
  before_action :find_user, only: [:edit, :update, :delete]
  before_action :get_roles, only: [:new, :edit]


	def index
		# Get all users
    @all_users = User.all
	end

	def new
    @user = User.new
	end

  def edit
    @user = User.find(params[:id])
    @address = @user.addresses
    @contact = @user.contacts
	end

  def create
    # Create new user
    if params.has_key?(:save)
      @user = User.new(request: :create, user: params[:user])
      if @user.save
        flash[:success] = 'Account has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the account'
      end
    end
    redirect_to users_path
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(request: :update, user: params[:user])
    redirect_to users_path
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_path, notice: 'User successfully deleted.'
    else
      redirect_to users_path, notice: 'User could not deleted.'
    end
  end

  # def save
  #   # Save changes from Add/Edit User page
  #   if params["user-id"].blank?
  #     # Create new user
  #     if User.useradd(params["user-email"])
  #       flash[:success] = 'User has been added successfully'
  #     else
  #       flash[:danger] = 'Oops! Unable to add the user'  # Log in error message
  #     end
  #   else
  #     # Edit user
  #     if User.useredit(params["user-id"], params["user-email"])
  #       flash[:success] = 'User has been edited successfully'
  #     else
  #       flash[:danger] = 'Oops! Unable to edit the user'  # Log in error message
  #     end
  #   end
  #   redirect_to users_path
  # end

	private
    def get_roles
      @roles = [{id: 1, name: "Admin"},{id: 2, name: "Enitity Admin"},{id: 3, name: "User"}]
    end

		def get_token
		  #set gloal var for token to be used in model, hack for now
		  $user_token = session[:token]
		end

    def find_user
      @user = User.find(params[:id])
    end

end
