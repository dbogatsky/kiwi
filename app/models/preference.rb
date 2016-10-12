class Preference < OrchardApiModel
  self.prefix = "/api/v1/company/settings/"

  def initialize(parsed = {}, param)
	@elements = parsed.kind_of?(Hash) ? parsed.values[0] : parsed
  end

end
