class BoUser < OrchardBoApiModel
  self.site = "#{ENV.fetch("ORCHARD_BO_API_HOST")}/companies/:company_id/"
  self.element_name = "users"

  # /backoffice/companies/:company_id/users/:id/impersonate
  def self.impersonate(company_id, user_id)
    url = "/backoffice/companies/#{company_id}/users/#{user_id}/impersonate"
    response = ActiveResource::Connection.new(OrchardBoApiModel.site).post(url, '', OrchardBoApiModel.headers)
  end
end