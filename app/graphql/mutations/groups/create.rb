module Mutations
  module Groups
    class Create < Mutations::AuthorizedMutation
      graphql_name 'CreateGroup'
      
      argument :group_attributes, Types::Groups::GroupInput, required: true

      field :errors, [String], null: true
      field :group, Types::Groups::GroupType, null: true

      def resolve(group_attributes:)
        options = set_options params: group_attributes.to_h
        BaseService.call(:group, :create, options)
      end
    end
  end
end
