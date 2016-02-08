class AccountStatus < OrchardApiModel
  cached_resource

	schema do
		attribute 'color', :string
    attribute 'description', :string
    attribute 'name', :string
	end
end