module Mutations
  module Permissions
    class Delete < Mutations::AuthorizedMutation
      graphql_name 'DeletePermission'
      
      argument :id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(id:)
        options = set_options params: { id: id }
        BaseService.call(:permission, :delete, options)
      end
    end
  end
end
