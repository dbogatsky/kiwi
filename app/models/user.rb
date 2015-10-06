require 'kiwi_service'

class User < KiwiServiceModel
  attr_accessor :username, :email, :password, :first_name, :last_name

  def self.authenticate(email, password)
    @token = Token.new
    @token.create(
        user = { "email": email, "password": password }
    )

    if  @token.token == nil
        false
    else 
        @token.token
    end 
  end

end
