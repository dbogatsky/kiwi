class Contact < OrchardApiModel
  self.prefix = "/accounts/:account_id/"
  CONTACT_TYPES = ["phone", "mobile", "fax", "email", "website", "twitter", "facebook", "youtube"]
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

