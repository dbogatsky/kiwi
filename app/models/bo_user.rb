class BoUser < OrchardBoApiModel
  self.site = "#{ENV.fetch("ORCHARD_BO_API_HOST")}/companies/:company_id/"
  self.element_name = "users"
end
