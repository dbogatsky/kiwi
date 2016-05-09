def sign_in(email, password)
  VCR.use_cassette('authentication-utility', record: :once) do
    OrchardApiModel.site = 'https://acme-api.code10.ca/api/v1'
    token = Token.authenticate(email, password)
    session[:user_id] = token.user_id
    session[:token] = token.token
  end
end
