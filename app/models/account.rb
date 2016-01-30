class Account < OrchardApiModel
  has_one :conversation
  has_many :contacts_attributes, :class_name => 'Contact'
  has_many :addresses_attributes, :class_name => 'Address'
  

  schema do
    # define each attribute separately
    attribute 'name', :string
    attribute 'status_id', :integer
    attribute 'assign_to', :string
    attribute 'shared_with', :string
    attribute 'about', :string
    attribute 'quick_facts', :string
    attribute 'avatar_url', :string
  end

end
