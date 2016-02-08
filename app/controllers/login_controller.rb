class LoginController < ApplicationController
  #exclude the following methods from the authentication filter since the user is not logged in yet
  before_filter :authentication, :except => [:index, :login, :forgot, :recover, :superadmin, :superadmin_auth]

  def index 
    if !session[:token].nil? 
      redirect_to dashboard_path
    else
      render :layout => false
    end
  end

  def login
    #abort(current_user.inspest)
    if params[:email] == APP_CONFIG['superadmin_email']
      return redirect_to login_superadmin_path
    end

    # Check username and password through the Authentication API
    begin
      token = Token.authenticate(params[:email], params[:password])
    rescue ActiveResource::ResourceNotFound, ActiveResource::BadRequest, ActiveResource::UnauthorizedAccess, ActiveResource::MethodNotAllowed, ActiveResource::ResourceConflict, ActiveResource::ResourceGone, ActiveResource::ResourceInvalid
      # 404 ResourceNotFound - No match found with email/password provided
      # 400 BadRequest - Incorrect request sent
      # 403 UnauthorizedAccess - No access to server
      # 405 MethodNotAllowed - Incorrect request
      # 409 ResourceConflict - ?
      # 410 ResourceGone - ?
      # 422 ResourceInvalid (rescued by save as validation errors) - ?
      flash[:danger] = 'Your email or password is incorrect.  Please try again.'  # Log in error message
      return redirect_to user_login_path
    rescue ActiveResource::ServerError, ActiveResource::ConnectionError
      # 500..599 ServerError - Server Error or unresponsive
      # Other ConnectionError - No connection or other error
      flash[:danger] = 'An unexpected error was encountered.'  # Log in error message
      return redirect_to user_login_path
    end

    unless token.nil?
      # Store user details into session
      session[:user_id] = token.user_id
      session[:token] = token.token

      #set gloal var for token to be used in model, hack for now
      set_current_user

      #cache some stuff for performance

      # Log the user in and redirect to the main page: Dashboard first?
      redirect_to dashboard_path
    end
  end

  #superadmin company choice
  def superadmin
    #check if superadmin token exists

    #get a list of companies

    #show layout
    render :layout => false
  end

  #superadmin login as company admin
  def superadmin_auth
    #check if superadmin token exists, if not boot user out

    #login as admin user

    #valid user so send to the dasbhoard
    #redirect_to dashboard_path
    exit #temp code to be removed after logic is placed
  end

  #forget password recover
  def forgot
    render :layout => false
  end

  def recover
    flash[:recover_success] = 'A link has been sent to your email to reset your password'
    redirect_to root_path
  end


  def destroy
    $user_token = nil
    session[:user_id] = nil
    session[:token] = nil
    redirect_to root_path
  end

  private

  def api_authentication_check
  end
end
