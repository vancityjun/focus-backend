require 'rails_helper'

RSpec.describe Resolvers::CurrentUser, type: :request do
  let!(:user) { create :user }
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
      execute_and_parse_graphql_response query: query, current_user: user
      expect(parse_graphql_response['currentUser']).to match(
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

    it 'none fetch without current_user' do
      execute_and_parse_graphql_response query: query, current_user: nil
      expect(parse_graphql_response['errors']).to be_truthy
    end
  end
end
