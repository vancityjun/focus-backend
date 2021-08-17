class Jwt::UserAuthenticator
  class << self
    def validate(request_headers)
      @request_headers = request_headers

      payload, _header = Jwt::TokenDecryptor.decrypt(token)
      user = User.find(payload['user_id'])
      return nil if user.archived?
      
      user
    rescue InvalidTokenError
    end

    def token
      return unless @request_headers['Authorization']

      @request_headers['Authorization'].split(' ').last
    end
  end
end
