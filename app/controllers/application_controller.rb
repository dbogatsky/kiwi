class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authentication

  def authentication
     if session[:user_token].nil?
      flash[:danger] = 'Sorry, your session has expired.  Please log in again.'  # Log in error message
      redirect_to root_path
     else 
      true
     end
  end
end
