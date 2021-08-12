module Types::Users
  class UserInput < Types::BaseInputObject
    argument :email, String, required: true
    argument :password, String, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :gender, String, required: false
    argument :country, String, required: false
    argument :region, String, required: false
    argument :city, String, required: false
  end
end