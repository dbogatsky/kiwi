require 'net/http/post/multipart'
class UsersController < ApplicationController
	load_and_authorize_resource
  before_action :get_token
  before_action :find_user, only: [:edit, :update, :destroy, :update_time_zone]


	def index
		# Get all users
    @all_users = User.find(:all, reload: true)
	end

	def new
    @user = User.new
	end

  def edit
    @address = @user.addresses
    @contact = @user.contacts
	end

  def create
    # Create new user
    @user = User.new(request: :create, user: params[:user])
    if @user.save
      save_avatar
      flash[:success] = 'User has been added successfully'
    else
      flash[:danger] = 'Oops! Unable to add the user'
    end
    redirect_to users_path
  end

  def update
    if @user.update_attributes(request: :update, user: params[:user], reload: true)
      save_avatar
      #in the event we are updating the logged in user refresh the detail
      if ( current_user.id == params['id'].to_i )
        @current_user = User.find(current_user.id, reload: true)
      end
      flash[:success] = 'User successfully updated!'
      redirect_to users_path
    else
      flash[:danger] = 'User not updated!'
      render :edit
    end
  end

  def update_time_zone
     if @user.update_attributes(request: :update, user: {time_zone: browser_timezone}, reload: true)
       flash[:success] = 'TimeZone successfully updated!'
     else
       flash[:danger] = 'TimeZone not updated!'
     end
     redirect_to :back
  end

  def not_update_time_zone
      session['time_zone_not_now'] = true
      redirect_to :back
  end

  def destroy
    if @user.destroy
      flash[:success] = 'User successfully deleted.'
      redirect_to users_path
    else
      flash[:danger] = 'User could not deleted.'
      redirect_to users_path
    end
  end

	private
		def get_token
		  #set gloal var for token to be used in model, hack for now
		  $user_token = session[:token]
		end

    def find_user
      @user = User.find(params[:id], reload: true)
    end

    def save_avatar
      if params[:user][:avatar]
        puts "sending avatar..."
        url = URI.parse("#{RequestStore.store[:api_url]}/users/#{@user.id}")
        #req = Net::HTTP::Put::Multipart.new url.path,  account: { :avatar => UploadIO.new(File.new(params[:avatar].tempfile), "image/jpeg", "image.jpg")}
        req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:user][:avatar].tempfile), "image/jpeg", "image.jpg")
        req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
        #req.add_field("Content-Type", "application/json")
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      end
    end

end
