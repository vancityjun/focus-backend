module Mutations
  module Users
    class Signup < Mutations::BaseMutation
      argument :password, String, required: true
      argument :user_attributes, Types::Users::UserInput, required: false

      field :errors, [String], null: true
      field :token, String, null: true

      def resolve(user_attributes:, password:)
        new_user = ::Users::NewUser.new user_attributes.to_h.merge(password: password)
        new_user.create
      end
    end
  end
end
