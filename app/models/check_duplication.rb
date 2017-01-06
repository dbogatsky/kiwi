class CheckDuplication < OrchardApiModel
  include ActiveResource::Singleton
  #cached_resource

  self.prefix = '/api/v1/accounts/'

  def initialize(parsed = {}, param)
    @elements = parsed.kind_of?(Hash) ? parsed.values[0] : parsed
  end

end
