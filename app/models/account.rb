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
			account_list = Array.new
			@accounts.accounts.each do |account|
				account_hash = Hash.new
				account_hash["id"] 		= account.id
				account_hash["name"] 	= account.name
				account_hash["status"] 	= account.status
				
				# get all addresses for this account
				account_addresses_list = Array.new
				account.addresses.each do |address|
					address_hash = Hash.new
					address_hash["id"] 			= address.id
					address_hash["street"] 		= address.street_address
					address_hash["city"] 		= address.city
					address_hash["region"] 		= address.region
					address_hash["postcode"] 	= address.postcode
					address_hash["country"] 	= address.country
					account_addresses_list.push(address_hash)
				end
				account_hash["addresses"] = account_addresses_list

				# get all the contact information for this account
				account_contacts_list = Array.new
				account.contacts.each do |contact|
					contact_hash = Hash.new
					contact_hash["id"] 			= contact.id
					contact_hash["name"] 		= contact.name
					contact_hash["value"] 		= contact.value
					contact_hash["type"] 		= contact.type
					account_contacts_list.push(contact_hash)
				end
				account_hash["contacts"] = account_contacts_list
				account_list.push(account_hash)
			end

			account_list		 
		end 		 
		
	end


	# Account - Find account by id
	def self.accountget(id)
			
		@account = OrchardApiAccounts.new
		
		#initate api call and catch any errors		
		begin
			@account.find(id)
		rescue ActiveRestClient::HTTPClientException, ActiveRestClient::HTTPServerException => e
			Rails.logger.error("API returned #{e.status} : #{e.result.message}")
		end

		#account did not return for some reason or is not set otherwise return the account_info
		if  @account == nil
		    false
		else
			account = @account.account
			account_info = Hash.new
			account_info["id"] 		= account.id
			account_info["name"] 	= account.name
			account_info["status"] 	= account.status
			
			# get all addresses for this account
			account_addresses_list = Array.new
			account.addresses.each do |address|
				address_hash = Hash.new
				address_hash["id"] 			= address.id
				address_hash["street"] 		= address.street_address
				address_hash["city"] 		= address.city
				address_hash["region"] 		= address.region
				address_hash["postcode"] 	= address.postcode
				address_hash["country"] 	= address.country
				account_addresses_list.push(address_hash)
			end
			account_info["addresses"] = account_addresses_list

			# get all the contact information for this account
			account_contacts_list = Array.new
			account.contacts.each do |contact|
				contact_hash = Hash.new
				contact_hash["id"] 			= contact.id
				contact_hash["name"] 		= contact.name
				contact_hash["value"] 		= contact.value
				contact_hash["type"] 		= contact.type
				account_contacts_list.push(contact_hash)
			end
			account_info["contacts"] = account_contacts_list

			account_info
		end 		 
		
	end


	# Account - Add account
	def self.accountadd(account_name, account_status_id, account_addresses, account_contacts)
			
		@accounts = OrchardApiAccounts.new
		
		account_addresses.each do |address|
			addresses_hash = Hash.new

		end

    account_contacts.each do |contact|
      contacts_hash = Hash.new
      
    end    


		#initate api call and catch any errors		
		begin
			@accounts.create(
				name: account_name,
				status: account_status_id,
				addresses: addresses_hash,
				contacts: contacts_hash
				)
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
