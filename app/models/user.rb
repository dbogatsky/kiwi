require 'kiwi_service'

class User < KiwiServiceModel
  attr_accessor :username, :email, :password, :first_name, :last_name

  def self.authenticate(email, password)
    if email == 'me@code10.ca'
      true
    else 
      false
    end 
  end

end
