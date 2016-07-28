class LoginController < ApplicationController
  # exclude the following methods from the authentication filter since the user is not logged in yet
  before_filter :authentication, except: [:index, :login, :forgot, :recover, :superadmin, :superadmin_auth]
  before_filter :notification_info, except: [:index, :login, :forgot, :recover, :superadmin, :superadmin_auth]
  # before_filter :accounts_cache, except: [:index, :login, :forgot, :recover, :destroy, :superadmin, :superadmin_auth]  # DIS001 disabled for now

  def index
    if !session[:token].nil?
      if (session[:user_id] == 'superadmin')
        redirect_to admin_companies_path
      else
        redirect_to dashboard_path
      end
    else
      render layout: false
    end
  end

  def login
    # Check username and password through the Authentication API
    begin
      if params[:email] == APP_CONFIG['superadmin_email']
        token = BoToken.authenticate(params[:email], params[:password])
      else
        token = Token.authenticate(params[:email], params[:password])
      end
    rescue ActiveResource::ResourceNotFound,    # 404 ResourceNotFound - No match found with email/password provided
            ActiveResource::BadRequest,         # 400 BadRequest - Incorrect request sent
            ActiveResource::UnauthorizedAccess, # 403 UnauthorizedAccess - No access to server
            ActiveResource::MethodNotAllowed,   # 405 MethodNotAllowed - Incorrect request
            ActiveResource::ResourceConflict,   # 409 ResourceConflict - ?
            ActiveResource::ResourceGone,       # 410 ResourceGone - ?
            ActiveResource::ResourceInvalid     # 422 ResourceInvalid (rescued by save as validation errors) - ?

      flash[:danger] = 'Your email or password is incorrect. Please try again.' # Login error message
      return redirect_to user_login_path

    rescue ActiveResource::ServerError, # 500..599 ServerError - Server Error or unresponsive
            ActiveResource::ConnectionError # Other ConnectionError - No connection or other error
      flash[:danger] = 'An unexpected error was encountered.'  # Log in error message
      return redirect_to user_login_path
    end

    unless token.nil?

      # handle superadmin case
      if params[:email] == APP_CONFIG['superadmin_email']
        session[:user_id] = 'superadmin'
        session[:token] = token.token
        # set_superadmin
        flash[:success] = 'Logged in as superadmin'
        redirect_to admin_companies_path
      else
        # Store user details into session
        session[:user_id] = token.user_id
        session[:token] = token.token

        # set gloal var for token to be used in model, hack for now
        set_current_user

        # Log the user in and redirect to the main page: Dashboard first?
        redirect_to session[:previous_url] || dashboard_path
      end
    end
  end

  def forgot
    redirect_to root_path
    #render layout: false
  end

  def change_password
    @user = User.find(params[:id])
    if request.patch?
      if @user.update_attributes(request: :update, user: params[:user], reload: true)
        flash[:success] = 'Password has been successfully updated.'
      else
        flash[:danger] = 'Oops! Unable to update the password'
      end
      redirect_to dashboard_path
    end
  end

  def recover
    flash[:recover_success] = 'A link has been sent to your email to reset your password'
    redirect_to root_path
  end

  def destroy
    RequestStore.store[:user_token] = nil
    session[:user_id] = nil
    session[:token] = nil
    current_user.logout unless current_user.nil?
    redirect_to root_path
  end

  private

  def api_authentication_check
  end
end
