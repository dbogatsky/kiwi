class Account
	#setup instance variables
	attr_accessor :status_id, :status_name, :status_color, :status_description


	def self.statuslist
			
		@account_status = OrchardApiAccountsStatuses.new
		
		#initate api call and catch any errors		
		begin
			@account_status.all
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#token did not return for some reason or is not set otherwise return the token
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

		#token did not return for some reason or is not set otherwise return the token
		if  @account_status == nil
		    false
		else
			true			 
		end 		 
		
	end


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

		#token did not return for some reason or is not set otherwise return the token
		if  @account_status == nil
		    false
		else
			true			 
		end 		 
		
	end


end
