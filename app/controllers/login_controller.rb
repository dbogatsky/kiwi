class LoginController < ApplicationController
  #exclude the following methods from the authentication filter since the user is not logged in yet
  before_filter :authentication, :except => [:index, :login, :forgot, :recover, :superadmin, :superadmin_auth]

  def index
    if !session[:token].nil?
      if(session[:user_id] == "superadmin")
        #should redirect to SU panel exiting for now
        exit
      else
        redirect_to dashboard_path
      end
    else
      render :layout => false
    end
  end

  def login

    # Check username and password through the Authentication API
    begin
      if params[:email] == APP_CONFIG['superadmin_email']
        token = Token.bo_authenticate(params[:email], params[:password])
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
            
      flash[:danger] = 'Your email or password is incorrect.  Please try again.'  # Log in error message
      return redirect_to user_login_path
      
    rescue ActiveResource::ServerError, # 500..599 ServerError - Server Error or unresponsive
            ActiveResource::ConnectionError # Other ConnectionError - No connection or other error      
      flash[:danger] = 'An unexpected error was encountered.'  # Log in error message
      return redirect_to user_login_path
    end

    unless token.nil?

      #handle superadmin case
      if params[:email] == APP_CONFIG['superadmin_email']
        session[:token] = token.token
        session[:user_id] = "superadmin"

        #should redirect to SU panel exiting for now
        exit
      else
        # Store user details into session
        session[:user_id] = token.user_id
        session[:token] = token.token

        #set gloal var for token to be used in model, hack for now
        set_current_user

        # Log the user in and redirect to the main page: Dashboard first?
        redirect_to dashboard_path
      end
    end
  end



  def forgot
    render :layout => false
  end


  def change_password
    @user = User.find(params[:id])
    if request.patch?
      @user.update_attributes(request: :update, user: params[:user], reload: true)
      redirect_to users_path, notice: 'Password successfully updated.'
    end
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
