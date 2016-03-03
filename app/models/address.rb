class Address < OrchardApiModel
  self.prefix = "/accounts/:account_id/"
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
