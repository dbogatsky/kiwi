class AccountStatus < OrchardApiModel
  cached_resource

	schema do
		attribute 'color', :string
    attribute 'description', :string
    attribute 'name', :string
	end
  STATUS = [{name: 'Lead', description: 'Indicates the account is a possible leads', color: '#3071a9'},
            {name: 'Open', description: 'The account is open', color: '#0eb057'},
            {name: 'Suspend', description: 'Suspended account', color: '#f38108'},
            {name: 'Closed', description:'Closed Account', color: '#999999'}]
end
