class AccountStatus < OrchardApiModel
	#self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/account_statuses"
	self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/"

	schema do
		attribute 'color', :string
    	attribute 'description', :string
    	attribute 'name', :string		
	end
end