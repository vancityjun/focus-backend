module Mutations
  module Groups
    class Delete < Mutations::AuthorizedMutation
      graphql_name 'DeleteGroup'
      
      argument :id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(id:)
        options = set_options params: { id: id }
        BaseService.call(:group, :delete, options)
      end
    end
  end
end
