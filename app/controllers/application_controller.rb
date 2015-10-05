class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenication

  def authenication
     if session[:user_token].nil?
      false
     else 
      true
     end
  end
end
