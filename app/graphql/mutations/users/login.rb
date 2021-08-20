module Mutations
  module Users
    class Login < Mutations::BaseMutation
      graphql_name 'LoginUser'

      argument :email, String, required: true
      argument :password, String, required: true

      field :errors, [String], null: true
      field :token, String, null: true

      def resolve(email:, password:)
        options = set_options params: { email: email, password: password }
        BaseService.call(:user, :login, options)
      end
    end
  end
end
