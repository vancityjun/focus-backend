class Jwt::TokenDecryptor
  class << self
    def decrypt(token)
      JWT.decode token, Rails.application.secrets.secret_key_base
    rescue
      raise InvalidTokenError
    end
  end
end

class InvalidTokenError < StandardError
end
