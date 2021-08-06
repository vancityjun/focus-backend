require 'rails_helper'

RSpec.describe Resolvers::CurrentUser, type: :request do
  let!(:user) { create :user }
  let!(:token) { generate_jwt_test_token(user) }

  let!(:query) do
    <<-GQL
      query {
        currentUser{
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
        }
      }
    GQL
  end

  describe 'currentUser' do
    it 'fetch with valid token' do
      post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
      expect(response.status).to eq(200)

      parsed_response = parse_response response.body
      expect(parsed_response['currentUser']).to match(
        {
          id: user.id.to_s,
          userAttributes: {
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            gender: user.gender,
            country: user.country,
            region: user.region,
            city: user.city,
          },
          fullName: "#{user.first_name} #{user.last_name}"
        }.with_indifferent_access
      )
    end

    it 'none fetch with invalid token' do
      post '/graphql', params: { query: query }, headers: { 'Authorization' => 'Bearer invalid' }
      expect(response.status).to eq(200)
      parsed_response = parse_response response.body
      expect(parsed_response['currentUser']).to be_nil
    end
  end
end
