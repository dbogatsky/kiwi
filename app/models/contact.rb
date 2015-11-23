class Contact < OrchardApiModel
  self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/accounts/:account_id/"

  schema do
    attribute 'type', :string
    attribute 'name', :string
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

