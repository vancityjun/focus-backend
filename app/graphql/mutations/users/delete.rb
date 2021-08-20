module Mutations
  module Users
    class Delete < Mutations::AuthorizedMutation
      graphql_name 'DeleteUser'

      argument :id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(id:)
        options = set_options params: { id: id }
        BaseService.call(:user, :delete, options)
      end
    end
  end
end
