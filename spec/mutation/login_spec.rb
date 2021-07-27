require 'rails_helper'

RSpec.describe Mutations::Login, type: :request do
  let!(:user) { create :user }

  let!(:query) do
    <<-GQL
      mutation login ($input: LoginInput!) {
        login (input: $input){
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
          errors
        }
      }
    GQL
  end
  it 'creates definition with examples' do
    variables = {
      email: 'jun@example.com',
      password: '1234'
    }
    result = GraphqlSchema.execute(
      query,
      variables: { input: variables }
    ).to_h.deep_symbolize_keys[:data][:login]

    expect(result[:user]).to match({
      id: user.id.to_s,
      token: user.token,
      fullName: user.full_name,
      userAttributes: {
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        gender: user.gender,
        country: user.country,
        region: user.region,
        city: user.city
      }
    })
  end

  context 'when email is not exist' do
    it 'returns user not found error' do
      variables = {
        email: 'ryan@example.com',
        password: '1234'
      }
      result = GraphqlSchema.execute(
        query,
        variables: { input: variables }
      ).to_h.deep_symbolize_keys[:data][:login]

      expect(result[:errors].count).to eq(1)
    end
  end

  context 'when password is not match' do
    it 'returns user not found error' do
      variables = {
        email: 'jun@example.com',
        password: '00615'
      }
      result = GraphqlSchema.execute(
        query,
        variables: { input: variables }
      ).to_h.deep_symbolize_keys[:data][:login]

      expect(result[:errors].count).to eq(1)
    end
  end
end
