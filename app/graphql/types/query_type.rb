module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :current_user, resolver: Resolvers::CurrentUser
    field :location_data, resolver: Resolvers::LocationData
    field :groups, resolver: Resolvers::Groups
  end
end
