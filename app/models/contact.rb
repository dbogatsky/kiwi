class Contact < OrchardApiModel
  self.site = "http://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1/accounts/:account_id/"
  CONTACT_TYPES = ["phone", "mobile", "email", "fax", "twitter", "facebook", "youtube"]
  belongs_to :account

  schema do
    attribute 'name', :string
    attribute 'type', :string
    attribute 'value', :string
  end

  def icon_name
    case type
    when "email"
      "envelope-o"
    else
      type
    end
  end
end

