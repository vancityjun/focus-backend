require 'rails_helper'

RSpec.describe Mutations::Register do
  it 'register' do
    query = <<-GQL
      mutation register ($input: RegisterInput!) {
        register (input: $input){
          user{
            id
            userAttributes{
              email
              firstName
              lastName
              gender
              country
              region
              city
            }
            fullName
            token
          }
        }
      }
    GQL

    variables = {
      password: '1234',
      userAttributes: {
        email: 'ryan@example.com',
        firstName: 'Ryan',
        lastName: 'Raynols',
        gender: 'male',
        country: 'Canada',
        city: 'Vancouver',
        region: 'West'
      }
    }
    result = GraphqlSchema.execute(
      query,
      variables: { input: variables }
    ).to_h.deep_symbolize_keys[:data][:register]

    user = User.last
    expect(result[:user]).to match({
      id: user.id.to_s,
      token: user.token,
      fullName: user.full_name
    }.merge(userAttributes: variables[:userAttributes]))
  end
end
