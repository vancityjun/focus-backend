require 'rails_helper'

RSpec.describe Mutations::Groups::Leave, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:attendee) { create :user, :attendee }
  let!(:attendee_token) { generate_jwt_test_token(attendee) }

  let!(:variables) do
    {
      id: group.id.to_s
    }
  end
    
  let!(:leave_group_query) do
    <<-GQL
      mutation leaveGroup ($input: LeaveGroupInput!) {
        leaveGroup (input: $input){
          status
          errors
        }
      }
    GQL
  end

  it 'leaves the group' do
    create :attendee, attendee: attendee, resource: group

    expect do
        execute_and_parse_graphql_response query: leave_group_query, variables: variables, current_user: attendee
      end.
        to change(attendee.attenables, :count).by(-1)

    expect(parse_graphql_response['leaveGroup']).to match(
      status: "Success to Leave the #{group.name}",
      errors: []
    )
  end

  it 'returns errors when attendee does not in the group' do
    expect do
        execute_and_parse_graphql_response query: leave_group_query, variables: variables, current_user: attendee
      end.
        to change(attendee.attenables, :count).by(0)

    expect(parse_graphql_response['leaveGroup']).to match(
      status: nil,
      errors: ['No record for attendee']
    )
  end
end
