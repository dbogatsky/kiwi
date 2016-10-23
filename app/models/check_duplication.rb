class CheckDuplication < OrchardApiModel
  include ActiveResource::Singleton
  cached_resource

  self.prefix = '/api/v1/accounts/'
end
