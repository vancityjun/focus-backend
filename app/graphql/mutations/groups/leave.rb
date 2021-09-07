module Mutations
  module Groups
    class Leave < Mutations::AuthorizedMutation
      graphql_name 'LeaveGroup'
      
      argument :id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(id:)
        options = set_options params: { id: id }
        BaseService.call(:group, :leave, options)
      end
    end
  end
end
