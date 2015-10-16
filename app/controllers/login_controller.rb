class LoginController < ApplicationController
	
	#exclude the following methods from the authentication filter since the user is not logged in yet
	before_filter :authentication, :except => [:index, :login, :forgot, :recover, :superadmin, :superadmin_auth]


	def index
		render :layout => false
	end
	

	def login 
		if params[:email] == APP_CONFIG['superadmin_email']
			#authenticate superadmin login
			
			#set superadmin token
			
			#go to next screen
			return redirect_to login_superadmin_path
		end
		
		# Check username and password through the Authentication API]
		if @user = User.authenticate(params[:email], params[:password])
		
		  # Store user details into session
		  session[:user] = @user
		  
		  #set gloal var for token to be used in model, hack for now
		  $user_token = session["user"]["token"]

		  #retrieve remainder details and store to session
		  @user_details = User.find(session["user"]["id"])
		  session["user"].merge!(@user_details)
		  
		  #cache some stuff for performance
		  #- account statuses
		  @account_statuses = Account.statuslist
		  session["account"] ||= {}
		  session["account"]["statuses"] = @account_statuses
		  
		
		  # Log the user in and redirect to the main page: Dashboard first? 
		  redirect_to dashboard_path
		
		else 
		  # Create an error message
		  flash[:danger] = 'Your email or password is incorrect'  # Log in error message  
		  redirect_to root_path
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
		session[:user] = nil
		redirect_to root_path
	end
	
	
	
	
  private

    def api_authentication_check

    end


end
