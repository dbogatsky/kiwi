class User < OrchardApiModel
  attr_accessor :token

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
