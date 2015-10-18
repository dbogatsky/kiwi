class Account
	#setup instance variables
	attr_accessor :status_id, :status_name, :status_color, :status_description


	# Account - Get all accounts
	def self.accountlist
			
		@accounts = OrchardApiAccounts.new
		
		#initate api call and catch any errors		
		begin
			@accounts.all
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#accounts did not return for some reason or is not set otherwise return the account_list
		if  @accounts == nil
		    false
		else
			@account_list = Array.new
			@accounts.each do |account|
				@account = Hash.new
				@account["id"] 				= account.id
				@account["name"] 			= account.name
				@account["color"] 			= account.color
				@account["description"] 	= account.description
				@account_list.push(@account)
			end
			@account_list		 
		end 		 
		
	end


	# Account - Find account by id
	def self.accountget(id)
			
		@accounts = OrchardApiAccounts.new
		
		#initate api call and catch any errors		
		begin
			@accounts.find(id)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#accounts did not return for some reason or is not set otherwise return the account_list
		if  @accounts == nil
		    false
		else
			@account_list = Array.new
			@accounts.each do |account|
				@account = Hash.new
				@account["id"] 				= account.id
				@account["name"] 			= account.name
				@account["color"] 			= account.color
				@account["description"] 	= account.description
				@account_list.push(@account)
			end
			@account_list		 
		end 		 
		
	end

	# Account - Add account
	def self.accountadd(account_details)
			
		@accounts = OrchardApiAccounts.new
		
		#initate api call and catch any errors		
		begin
			@accounts.create
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#accounts did not return for some reason or is not set otherwise return the account_list
		if  @accounts == nil
		    false
		else
			@account_list = Array.new
			@accounts.each do |account|
				@account = Hash.new
				@account["id"] 				= account.id
				@account["name"] 			= account.name
				@account["color"] 			= account.color
				@account["description"] 	= account.description
				@account_list.push(@account)
			end
			@account_list		 
		end 		 
		
	end


	# Account - Edit account
	def self.accountedit(account_details)
			
		@accounts = OrchardApiAccounts.new
		
		#initate api call and catch any errors		
		begin
			@accounts.save
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#accounts did not return for some reason or is not set otherwise return the account_list
		if  @accounts == nil
		    false
		else
			@account_list = Array.new
			@accounts.each do |account|
				@account = Hash.new
				@account["id"] 				= account.id
				@account["name"] 			= account.name
				@account["color"] 			= account.color
				@account["description"] 	= account.description
				@account_list.push(@account)
			end
			@account_list		 
		end 		 
		
	end



	# Account Status - Get all account statuses
	def self.statuslist
			
		@account_status = OrchardApiAccountsStatuses.new
		
		#initate api call and catch any errors		
		begin
			@account_status.all
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#account_status did not return for some reason or is not set otherwise return the status_list
		if  @account_status == nil
		    false
		else
			@status_list = Array.new
			@account_status.account_statuses.each do |status|
				@status = Hash.new
				@status["id"] 			= status.id
				@status["name"] 		= status.name
				@status["color"] 		= status.color
				@status["description"] 	= status.description
				@status_list.push(@status)
			end
			@status_list		 
		end 		 
		
	end	

	# Account Status - Add account status
	def self.statusadd(status_name, status_color, status_description)
			
		@account_status = OrchardApiAccountsStatuses.new
		
		#initate api call and catch any errors		
		begin
			@account_status.create(
				name: status_name,
				color: status_color,
				description: status_description
			)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#Return false if add account status failed, otherwise true
		if  @account_status == nil
		    false
		else
			true			 
		end 		 
		
	end

	# Account Status - Edit account status
	def self.statusedit(status_id, status_name, status_color, status_description)
			
		@account_status = OrchardApiAccountsStatuses.new
		
		#initate api call and catch any errors		
		begin
			@account_status.save(
				id: status_id,
				name: status_name,
				color: status_color,
				description: status_description
			)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#Return false if edit account status failed, otherwise true
		if  @account_status == nil
		    false
		else
			true			 
		end 		 
		
	end




end
