require 'net/http/post/multipart'
class Admin::UsersController < Admin::AdminController
  before_action :get_token
  before_action :find_company, only: [:edit, :update, :change_password]
  before_action :find_user, only: [:edit, :update, :destroy]

  def index
    @all_users = User.find(:all, reload: true)
  end

  def new
    @user = BoUser.new
    @address = []
    @contacts = []
    @company_address = BoCompany.find(params[:company_id]).addresses.first
  end

  def edit
    @address = @user.addresses.last
    @contact = @user.contacts
  end

  def create
    # Create new user
    params[:user][:addresses_attributes] = params[:user][:addresses_attributes].values
    @user = BoUser.new(request: :create, user: params[:user], company_id: params[:company_id], reload: true)
    begin
      if @user.save
        save_avatar
        flash[:success] = 'User has been added successfully'
      else
        flash[:danger] = 'Oops! Unable to add the user'
      end
    rescue NoMethodError
      flash[:danger] = 'User can not be created due to that the email address already exists in the system.'
      redirect_to admin_companies_path
    end
  end

  def update
    params[:user][:addresses_attributes] = params[:user][:addresses_attributes].values
    if @user.update_attributes(request: :update, user: params[:user], company_id: params[:company_id], reload: true)
      save_avatar
      flash[:success] = 'User successfully updated!'
      redirect_to admin_company_path(params[:company_id])
    else
      flash[:danger] = 'User not updated!'
      redirect_to edit_admin_company_user_path(company_id:  @company.id, id: @user.id)
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = 'User successfully deleted.'
    else
      flash[:danger] = 'User could not deleted.'
    end
    redirect_to admin_company_path(params[:company_id])
  end

  def change_password
    @user = BoUser.find(params[:user_id], params: { company_id: params[:company_id] })
    if request.patch?
      if @user.update_attributes(request: :update, user: params[:user], company_id: params[:company_id], reload: true)
        flash[:success] = 'Password successfully updated.'
      else
        flash[:danger] = 'Password could not updated.'
      end
      redirect_to admin_company_path(params[:company_id])
    end
  end

  private

  def get_token
    # set gloal var for token to be used in model, hack for now
    $user_token = session[:token]
  end

  def find_user
    @user = BoUser.find(params[:id], params: { company_id: params[:company_id] })
  end

  def find_company
    @company = BoCompany.find(params[:company_id])
  end

  def save_avatar
    if params[:user][:avatar]
      puts 'sending avatar...'
      url = URI.parse("#{ENV['ORCHARD_BO_API_HOST']}/companies/#{params[:company_id]}/users/#{@user.id}")
      req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:user][:avatar].tempfile), 'image/jpeg', 'image.jpg')
      req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end
end
