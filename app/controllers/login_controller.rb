class LoginController < ApplicationController
	
	#exclude the following methods from the authentication filter since the user is not logged in yet
	before_filter :authentication, :except => [:index, :login, :forgot, :recover]


	def index
		render :layout => false
	end
	
	
	def login 
		# Check username and password through the Authentication API]
		if @auth = User.authenticate(params[:email], params[:password])
		
		  # Store username into session
		  session[:user_token] = @auth
		
		  # Log the user in and redirect to the main page: Dashboard first? 
		  redirect_to dashboard_path
		
		else 
		  # Create an error message
		  flash[:danger] = 'Your email or password is incorrect'  # Log in error message  
		  redirect_to root_path
		end 
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
		session[:user_token] = nil
		redirect_to root_path
	end
	
	
	
	
  private

    def api_authentication_check

    end


end
