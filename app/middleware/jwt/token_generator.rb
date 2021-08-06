class Jwt::TokenGenerator
  class << self
    def issue_token(payload)
      # TODO: need to update token generation algorithm
      JWT.encode payload, Rails.application.secrets.secret_key_base
    end
  end
end
