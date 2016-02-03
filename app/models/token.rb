class Token < OrchardApiModel
  	
  include ActiveResource::Singleton
  #self.headers['Authorization'] = ''
  
  def self.headers
    new_headers = static_headers.clone
    new_headers['Authorization'] = ''
    new_headers
  end

  def self.authenticate(email, password)
    #initate api call and catch any errors
    @token = Token.create(
      app_key: APP_CONFIG['api_app_key'],
      user: {
        email: email,
        password: password
      }
    )
  end
end

