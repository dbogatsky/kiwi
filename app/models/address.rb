class Address < OrchardApiModel
  self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/accounts/:account_id/"

  schema do
    attribute 'name', :string
    attribute 'street_address', :string
    attribute 'postcode', :string
    attribute 'city', :string
    attribute 'region', :string
    attribute 'country', :string
  end

end


