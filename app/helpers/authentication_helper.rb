module AuthenticationHelper

  #
  def authenticate_user(username, password)

    if username == 'tester' && password == 'pass123'
      return true
    else
      return false
    end

  end

end
