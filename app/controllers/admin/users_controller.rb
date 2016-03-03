class Admin::UsersController < Admin::AdminController
	before_action :get_token
  # before_action :find_company, only: [:edit, :update]
  # before_action :find_user, only: [:edit, :update]

  def index
    @all_users = User.find(:all, reload: true)
  end

  def new
    @user = BoUser.new
    @address = []
    @contacts = []
	end

 #  def edit
 #    @address = @user.addresses
 #    @contact = @user.contacts
	# end

  def create
    # Create new user
    params[:user][:addresses_attributes] = params[:user][:addresses_attributes].values
    @user = BoUser.new(request: :create, user: params[:user], company_id: params[:company_id], reload: true)
    if @user.save
      save_avatar
      flash[:success] = 'User has been added successfully'
    else
      flash[:danger] = 'Oops! Unable to add the user'
    end
    redirect_to admin_company_path(params[:company_id])
  end

  # def update
  #   if @user.update_attributes(request: :update, user: params[:user], reload: true)
  #     save_avatar
  #     #in the event we are updating the logged in user refresh the detail
  #     if ( current_user.id == params['id'].to_i )
  #       @current_user = User.find(current_user.id, reload: true)
  #     end
  #     flash[:success] = 'User successfully updated!'
  #     redirect_to users_path
  #   else
  #     flash[:danger] = 'User not updated!'
  #     render :edit
  #   end
  # end

private

	def get_token
	  #set gloal var for token to be used in model, hack for now
	  $user_token = session[:token]
	end

  # def find_user
  #   @user = BoUser.find(params[:id], reload: true)
  # end

  # def find_company
  #   @company = BoCompany.find(params[:company_id])
  # end

  def save_avatar
    if params[:user][:avatar]
      puts "sending avatar..."
      url = URI.parse("#{ENV.fetch("ORCHARD_API_HOST")}/users/#{@user.id}")
      req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:user][:avatar].tempfile), "image/jpeg", "image.jpg")
      req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
      res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
      end
    end
  end
end
