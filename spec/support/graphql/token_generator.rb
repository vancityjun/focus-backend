module GraphQL
  module TokenGenerator
    def generate_jwt_test_token(user)
      Jwt::TokenGenerator.issue_token user.for_token
    end
  end
end
