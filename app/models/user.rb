class User < OrchardApiModel
  cached_resource ttl: 900

  schema do
    # define each attribute separately
    attribute 'status', :string
    attribute 'title', :string
    attribute 'first_name', :string
    attribute 'last_name', :string
    attribute 'email', :string
    attribute 'company_id', :integer
    attribute 'company_entity_id', :string
    attribute 'status_id', :integer
    attribute 'encrypted_password', :string
    attribute 'status', :string
    attribute 'time_zone', :string
    attribute 'locale', :string
    attribute 'avatar_url', :string
  end

  def logout
    ActiveResource::Connection.new(OrchardApiModel.site).delete('/api/v1/logout')
  end
end
