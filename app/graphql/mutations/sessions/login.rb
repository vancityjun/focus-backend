module Mutations
  module Sessions
    class Login < Mutations::BaseMutation
      graphql_name 'LoginUser'

      argument :email, String, required: true
      argument :password, String, required: true

      field :errors, [String], null: true
      field :token, String, null: true

      def resolve(email:, password:)
        user = User.authenticate email, password
        
        if user.blank?
          invalid_response
        elsif user.archived?
          archived_user
        else
          token = Jwt::TokenGenerator.issue_token user.for_token
          { token: token, errors: [] }
        end
      end

      protected

      def invalid_response
        { token: nil, errors: ['Invalid email or password.'] }
      end

      def archived_user
        { token: nil, errors: ['This User is deactivated.'] }
      end
    end
  end
end
