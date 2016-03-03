class Address < OrchardApiModel
  self.site = "http://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1/accounts/:account_id/"
  belongs_to :account

  schema do
    attribute 'name', :string
    attribute 'street_address', :string
    attribute 'postcode', :string
    attribute 'city', :string
    attribute 'region', :string
    attribute 'country', :string
  end
end