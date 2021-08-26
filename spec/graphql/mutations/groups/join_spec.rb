require 'rails_helper'

RSpec.describe Mutations::Groups::Join, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:attendee) { create :user, :attendee }
  let!(:attendee_token) { generate_jwt_test_token(attendee) }

  let!(:variables) do
    {
      input: {
        id: group.id.to_s
      }
    }
  end
    
  let!(:join_group_query) do
    <<-GQL
      mutation joinGroup ($input: JoinGroupInput!) {
        joinGroup (input: $input){
          status
          errors
        }
      }
    GQL
  end

  it 'joins the group' do
    expect do
      post '/graphql', params: { query: join_group_query, variables: variables.to_json }, headers: { 'Authorization' => "Bearer #{attendee_token}" }
    end.
      to change(attendee.attenables, :count).by(1)
    
    expect(response.status).to eq(200)

    parsed_response = parse_response response.body
    expect(parsed_response['joinGroup']).to match(
      status: "Success to Join the #{group.name}",
      errors: []
    )
  end

  it 'returns errors when attendee already joined the group' do
    create :attendee, attendee: attendee, resource: group

    expect do
      post '/graphql', params: { query: join_group_query, variables: variables.to_json }, headers: { 'Authorization' => "Bearer #{attendee_token}" }
    end.
      to change(attendee.attenables, :count).by(0)

    parsed_response = parse_response response.body
    expect(parsed_response['joinGroup']).to match(
      status: nil,
      errors: ['Already Join the Group']
    )
  end
end
