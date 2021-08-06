module Types
  class MutationType < Types::BaseObject
    field :signup, mutation: Mutations::Users::Signup
    field :login, mutation: Mutations::Sessions::Login
  end
end
