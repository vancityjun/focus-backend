module Mutations
  module Users
    class Signup < Mutations::BaseMutation
      graphql_name 'SignupUser'
      
      argument :password, String, required: true
      argument :email, String, required: true
      argument :user_attributes, Types::Users::UserInput, required: false

      field :errors, [String], null: true
      field :token, String, null: true

      def resolve(user_attributes:, password:, email:)
        options = set_options params: user_attributes.to_h.merge({password: password, email: email})
        BaseService.call(:user, :create, options)
      end
    end
  end
end
