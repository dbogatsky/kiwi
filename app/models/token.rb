class Token < OrchardApiModel
  include ActiveResource::Singleton
  self.headers['Authorization'] = ''

end

