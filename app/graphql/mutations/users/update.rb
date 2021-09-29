module Mutations
  module Users
    class Update < Mutations::AuthorizedMutation
      graphql_name 'UpdateUser'

      argument :id, String, required: true
      argument :password, String, required: false
      argument :email, String, required: false
      argument :user_attributes, Types::Users::UserInput, required: false

      field :errors, [String], null: true
      field :user, Types::Users::UserType, null: true

      def resolve(user_attributes: nil, password: nil, id:, email:)
        # email update need to be separated later (with email confirmation)
        options = 
          if password.blank?
            set_options params: user_attributes.to_h.merge({id: id, email: email})
          else
            set_options params: { id: id, password: password, email: email}
          end

        BaseService.call(:user, :update, options)
      end
    end
  end
end
