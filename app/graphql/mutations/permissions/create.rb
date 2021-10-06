module Mutations
  module Permissions
    class Create < Mutations::AuthorizedMutation
      graphql_name 'AddPermission'
      
      argument :user_id, String, required: true
      argument :group_id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(user_id:, group_id:)
        options = set_options params: { user_id: user_id, group_id: group_id }
        BaseService.call(:permission, :create, options)
      end
    end
  end
end
