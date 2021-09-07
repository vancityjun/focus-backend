module Types
  class MutationType < Types::BaseObject
    # User
    field :signup, mutation: Mutations::Users::Signup
    field :login, mutation: Mutations::Users::Login
    field :update_user, mutation: Mutations::Users::Update
    field :delete_user, mutation: Mutations::Users::Delete

    # Group
    field :create_group, mutation: Mutations::Groups::Create
    field :update_group, mutation: Mutations::Groups::Update
    field :delete_group, mutation: Mutations::Groups::Delete
    field :join_group, mutation: Mutations::Groups::Join
    field :leave_group, mutation: Mutations::Groups::Leave
  end
end
