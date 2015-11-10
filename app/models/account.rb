class Account < OrchardApiModel
  schema do
    # define each attribute separately
    attribute 'name', :string
    attribute 'status_id', :integer
    attribute 'assign_to', :string
    attribute 'shared_with', :string
    attribute 'about', :string
    attribute 'facts', :string
    attribute 'avatar', :string

=begin
    attribute 'addresses_attributes', Array do
      attribute 'street_address', :string
      attribute 'city', :string
      attribute 'postcode', :string
      attribute 'country', :string
    end
    attribute 'contacts_attributes', Array do
      attribute 'name', :string
      attribute 'value', :string
      attribute 'type', :string
    end    
=end
  end

end
