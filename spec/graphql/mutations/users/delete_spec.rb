require 'rails_helper'

RSpec.describe Mutations::Users::Delete, type: :request do
  let!(:user) { create :user }
  let!(:token) { generate_jwt_test_token(user) }
  let!(:previous_user_attr) { user }
  
  let!(:variables) do
    {
      input: {
        id: user.id
      }
    }
  end

  let!(:delete_user_query) do
    <<-GQL
      mutation deleteUser ($input: DeleteUserInput!) {
        deleteUser (input: $input){
          status
          errors
        }
      }
    GQL
  end

  describe 'with valid variables' do
    freeze_time! { Time.zone.parse('2021-08-17 09:00') }

    it 'archive user' do
      expect do
        post '/graphql', params: { query: delete_user_query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
      end.
        to change(User, :count).by(0)

      expect(response.status).to eq(200)

      parsed_response = parse_response response.body
      expect(parsed_response['deleteUser']).to match(
        status: 'Success to Delete User',
        errors: []
      )

      expect(user.reload).to have_attributes(
        archived: true,
        archived_at: now
      )
    end
  end

  describe 'with invalid variables' do
    it 'returns errors when token does not existed' do
      post '/graphql', params: { query: delete_user_query, variables: variables }
      parsed_response = parse_response response.body
      expect(parsed_response['deleteUser']).to match(
        status: nil,
        errors: ['Invalid user']
      )
    end

    it 'returns errors when token is invalid' do
      post '/graphql', params: { query: delete_user_query, variables: variables }, headers: { 'Authorization' => "Bearer Invalid" }
      parsed_response = parse_response response.body
      expect(parsed_response['deleteUser']).to match(
        status: nil,
        errors: ['Invalid user']
      )
    end
  end
end
