module Types::Users
  class AttributesType < Types::BaseObject
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :gender, String, null: true
    field :country, String, null: true
    field :region, String, null: true
    field :city, String, null: true
  end

  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :full_name, String, null: false
    field :user_attributes, Types::Users::AttributesType, null: false
    def user_attributes
      object
    end
  end
end
