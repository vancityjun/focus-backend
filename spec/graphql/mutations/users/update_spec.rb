require 'rails_helper'

RSpec.describe Mutations::Users::Update, type: :request do
  let!(:user) { create :user }
  let!(:token) { generate_jwt_test_token(user) }
  let!(:previous_user_attr) { user }

  let!(:variables) do
    {
      input: {
        id: user.id,
        email: 'vince@example.com',
        userAttributes: {
          firstName: 'Vince',
          lastName: 'Yoon',
          gender: 'male',
          country: 'Canada',
          city: 'Vancouver',
          region: 'West'
        }
      }
    }
  end
    
  let!(:update_user_query) do
    <<-GQL
      mutation updateUser ($input: UpdateUserInput!) {
        updateUser (input: $input){
          user {
            id,
            fullName,
            email,
            userAttributes{
              firstName,
              lastName,
              gender,
              country,
              city,
              region,
            }
          }
          errors
        }
      }
    GQL
  end

  describe 'with valid variables' do
    it 'updates user attributes' do
      expect do
        post '/graphql', params: { query: update_user_query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
      end.
        to change { user.reload.email }.from(previous_user_attr.email).to(variables[:input][:email]).
        and change { user.first_name }.from(previous_user_attr.first_name).to(variables[:input][:userAttributes][:firstName]).
        and change { user.last_name }.from(previous_user_attr.last_name).to(variables[:input][:userAttributes][:lastName])

      expect(response.status).to eq(200)

      parsed_response = parse_response response.body
      expect(parsed_response['updateUser']['user']).to match(
        {
          id: user.id.to_s,
          email: variables[:input][:email],
          userAttributes: {
            firstName: variables[:input][:userAttributes][:firstName],
            lastName: variables[:input][:userAttributes][:lastName],
            gender: variables[:input][:userAttributes][:gender],
            country: variables[:input][:userAttributes][:country],
            region: variables[:input][:userAttributes][:region],
            city: variables[:input][:userAttributes][:city],
          },
          fullName: "#{variables[:input][:userAttributes][:firstName]} #{variables[:input][:userAttributes][:lastName]}"
        }.with_indifferent_access
      )
    end

    it 'updates user password' do
      variables = {
        input: {
          id: user.id,
          password: '87654321',
          email: user.email
        }
      }
      post '/graphql', params: { query: update_user_query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
      user.reload
      expect(response.status).to eq(200)
      expect(Sorcery::CryptoProviders::BCrypt.matches? user.crypted_password, '87654321', user.salt).to be true
    end
  end

  describe 'with invalid variables' do
    it 'returns errors when token does not existed' do
      post '/graphql', params: { query: update_user_query, variables: variables }
      parsed_response = parse_response response.body
      expect(parsed_response['updateUser']).to match(
        user: nil,
        errors: ['Invalid user']
      )
    end

    it 'returns errors when token is invalid' do
      post '/graphql', params: { query: update_user_query, variables: variables }, headers: { 'Authorization' => "Bearer Invalid" }
      parsed_response = parse_response response.body
      expect(parsed_response['updateUser']).to match(
        user: nil,
        errors: ['Invalid user']
      )
    end

    it 'returns errors when user_id is invalid' do
      post '/graphql', params: { query: update_user_query, variables: variables.deep_merge(input: { id: '100' }) }, headers: { 'Authorization' => "Bearer #{token}" }
      parsed_response = parse_response response.body
      expect(parsed_response['updateUser']).to match(
        user: nil,
        errors: ['Invalid user']
      )
    end
  end
end
