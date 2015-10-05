class LoginController < ApplicationController

  def index
  end


  def login 
    # Check username and password through the Authentication API
   if @auth = User.authenticate(params[:email], params[:password])
      # Store username into session
      session[:user_token] = params[:email]
      # Log the user in and redirect to the main page: Dashboard first? 
      redirect_to dashboard_path
      # render 'show'
    else 
      # Create an error message
      flash[:danger] = 'Error:  Incorrect username or password.  Please try again...'  # Log in error message  
      render 'index'
    end 
  end

  def destroy
  end

  
  private

    def api_authentication_check

    end


end
