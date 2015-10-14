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
		    @token.token
		end 
	end
	
	
	def self.details
			
		@user = OrchardApiUser.new
		#initate api call and catch any errors		
		begin
			@user.userdetails
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#token did not return for some reason or is not set otherwise return the token
		if  @user == nil
		    false
		else 
		    @user
		end 		 
		 
		
	end

end
