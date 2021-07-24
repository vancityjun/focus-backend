module Mutations
  class Register < Mutations::BaseMutation
    argument :password, String, required: true
    argument :user_attributes, Types::UserAttributes, required: false

    field :errors, [String], null: true
    field :user, Types::UserType, null: false

    def resolve(user_attributes:, password:)
      user = User.new user_attributes.to_h.merge(password: password)

      if user.save!
        context[:current_user] = user
        {
          user: user,
          errors: []
        }
      else
        {
          errors: ['register failed']
        }
      end
    end
  end
end
