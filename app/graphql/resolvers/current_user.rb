module Resolvers
  class CurrentUser < Resolvers::Base
    type Types::Users::UserType, null: true

    description 'Fetch the info for the current user'
    argument :id, String, required: false, default_value: ''

    def resolve(_params)
      current_user
    end
  end
end
