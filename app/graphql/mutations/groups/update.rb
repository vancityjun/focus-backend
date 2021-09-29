module Mutations
  module Groups
    class Update < Mutations::AuthorizedMutation
      graphql_name 'UpdateGroup'
      
      argument :id, String, required: true
      argument :group_attributes, Types::Groups::GroupInput, required: true

      field :errors, [String], null: true
      field :group, Types::Groups::GroupType, null: true

      def resolve(group_attributes: nil, id:)
        options = set_options params: group_attributes.to_h.merge(id: id)
        BaseService.call(:group, :update, options)
      end
    end
  end
end
