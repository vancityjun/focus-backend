module Types::Groups
  class GroupType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :description, String, null: false
    field :slots, Integer, null: false
    field :country, String, null: true
    field :region, String, null: true
    field :city, String, null: true
    field :street_address, String, null: true
    field :post_code, String, null: true
    field :private, Boolean, null: true
    field :owner, Types::Users::UserType, null: false
    field :attend, Boolean, null: true
    def owner
      object.owner
    end

    def attend
      object.attenables.where(attendee: current_user).exists?
    end
  end
end
