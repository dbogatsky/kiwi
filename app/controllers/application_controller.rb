class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authentication
   
  helper_method :current_user, :logged_in?

  private

  def authentication
     if session[:token].nil?
      flash[:danger] = 'Your session has expired.  Please log in again.'  # Log in error message
      redirect_to root_path
     else 
       set_current_user
     end
  end

  def set_current_user
    if session[:user].nil?
      $user_token = session[:token]
      @current_user = User.find(session[:user_id])
      @current_user.id = session[:user_id]
      session[:user] = @current_user.to_yaml
    else
      @current_user = YAML.load(session[:user])
    end
  end

  def current_user
    @current_user = YAML.load(session[:user])
  end

  def logged_in?
    current_user != nil
  end
end
