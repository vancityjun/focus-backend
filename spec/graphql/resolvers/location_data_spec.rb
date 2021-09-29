require 'rails_helper'

RSpec.describe Resolvers::LocationData, type: :request do
  let!(:user) { create :user }
  let!(:token) { generate_jwt_test_token(user) }

  let!(:query) do
    <<-GQL
      query {
        locationData {
          label
          value
        }
      }
    GQL
  end

  describe 'locationData' do
    it 'fetch all countries' do
      response = execute_and_parse_graphql_response query: query, variables: {country: nil, region: nil}

      expect(response['locationData']).to all( match(kind_of Hash))
    end

    it 'fetch all regions' do
      response = execute_and_parse_graphql_response query: query, variables: {country: 'us', region: nil}

      expect(response['locationData']).to all( match(kind_of Hash))
    end

    it 'fetch all cities' do
      response = execute_and_parse_graphql_response query: query, variables: {country: 'us', region: 'ca'}

      expect(response['locationData']).to all( match(kind_of Hash))
    end
  end
end
