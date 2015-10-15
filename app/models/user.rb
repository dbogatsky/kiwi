class User
	
	#setup instance variables
	attr_accessor :email, :password
	
	#
	#athentication method to verify credentials
	#
	def self.authenticate(email, password)
	
		#create new token object for auth
		@token = OrchardApiToken.new 
		
		#initate api call and catch any errors
		begin
			@token.create(
			user: {
				email: email,
				password: password
				}
			)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end
		
		#token did not return for some reason or is not set otherwise return the token
		if  @token.token == nil
		    false
		else 
			@user = Hash.new	
			@user["token"] 	= @token.token
			@user["id"] 	= @token.user_id
			@user["email"] 	= @token.email
			@user
		end 
	end
	
	
	def self.find(id)
			
		@user = OrchardApiUser.new
		
		#initate api call and catch any errors		
		begin
			@user.find(id)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end
		
		#token did not return for some reason or is not set otherwise return the token
		if  @user == nil
		    false
		else
			@person = Hash.new
			@person["first_name"] 	= @user.user.first_name
			@person["last_name"] 	= @user.user.last_name
			@person["avatar_url"] 	= @user.user.avatar_url
			@person["addresses"] 	= @user.user.addresses
			@person["contacts"] 	= @user.user.contacts
			@person["roles"] 		= @user.user.roles				 
		    @person
		end 		 
		 
		
	end

end
