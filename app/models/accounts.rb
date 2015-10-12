class Account
	
	#setup instance variables
	#attr_accessor :email, :password
	
	##
	#athentication method to verify credentials
	##
	def self.get_all(user_token)
	
		#object for accounts
		@accounts = OrchardApiAccounts.new 
		
		#initate api call and catch any errors
		begin
			@accounts.all(user_token)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end
		  
		#accounts did not return for some reason or is not set otherwise return the accounts
		if  @accounts.name == nil
		    false
		else 
		    @accounts
		end 
	end

end
