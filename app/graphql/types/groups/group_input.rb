module Types::Groups
  class GroupInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :description, String, required: true
    argument :slots, Integer, required: true
    argument :country, String, required: false
    argument :region, String, required: false
    argument :city, String, required: false
    argument :street_address, String, required: false
    argument :post_code, String, required: false
    argument :private, Boolean, required: false
  end
end
