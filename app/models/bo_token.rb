class BoToken < OrchardBoApiModel

  #can use self.element_name however it will pluralize
  #self.collection_name will use as is
  self.collection_name = "token"

  def self.headers
    new_headers = static_headers.clone
    new_headers['Authorization'] = ''
    new_headers
  end

  def self.authenticate(email, password)
    #initate api call and catch any errors
    @token = BoToken.create(
      app_key: APP_CONFIG['api_app_key'],
      support_user: {
        email: email,
        password: password
      }
    )
  end  
end


