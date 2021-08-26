module Mutations
  module Groups
    class Join < Mutations::AuthorizedMutation
      graphql_name 'JoinGroup'
      
      argument :id, String, required: true

      field :errors, [String], null: true
      field :status, String, null: true

      def resolve(id:)
        options = set_options params: { id: id }
        BaseService.call(:group, :join, options)
      end
    end
  end
end
