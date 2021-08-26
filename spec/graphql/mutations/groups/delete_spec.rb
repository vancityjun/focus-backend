require 'rails_helper'

RSpec.describe Mutations::Groups::Delete, type: :request do
  let!(:user) { create :user, :owner }
  let!(:token) { generate_jwt_test_token(user) }
  let!(:group) { create :group, owner: user }

  let!(:variables) do
    {
      input: {
        id: group.id.to_s
      }
    }
  end
    
  let!(:delete_group_query) do
    <<-GQL
      mutation deleteGroup ($input: DeleteGroupInput!) {
        deleteGroup (input: $input){
          status
          errors
        }
      }
    GQL
  end

  describe 'with valid variables' do
    it 'archives the group' do
      expect do
        post '/graphql', params: { query: delete_group_query, variables: variables.to_json }, headers: { 'Authorization' => "Bearer #{token}" }
      end.
        to change(user.groups, :count).by(0).
        and change(Attendee, :count).by(-1)
      
      expect(response.status).to eq(200)

      parsed_response = parse_response response.body
      expect(parsed_response['deleteGroup']).to match(
        status: 'Success to Delete Group',
        errors: []
      )
    end
  end

  describe 'with invalid variables' do
    it 'returns errors when token does not existed' do
      post '/graphql', params: { query: delete_group_query, variables: variables.to_json }
      parsed_response = parse_response response.body
      expect(parsed_response['deleteGroup']).to match(
        status: nil,
        errors: ['Invalid user']
      )
    end
  end
end
