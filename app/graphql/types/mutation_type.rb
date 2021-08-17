module Types
  class MutationType < Types::BaseObject
    field :signup, mutation: Mutations::Users::Signup
    field :login, mutation: Mutations::Sessions::Login
    field :update_user, mutation: Mutations::Users::Update
    field :delete_user, mutation: Mutations::Users::Delete
  end
end
