class User < OrchardApiModel
  def self.authenticate(email, password)

    #initate api call and catch any errors
    t = Token.create(
      app_key: APP_CONFIG['api_app_key'],
      user: {
        email: email,
        password: password
      }
    )

    return t.user_id, t.token unless t.token.nil?
  end
end
