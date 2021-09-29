require 'rails_helper'

RSpec.describe Mutations::Groups::Leave, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:attendee) { create :user, :attendee }
  let!(:attenable) { create :attendee, attendee: attendee, resource: group}

  let!(:variables) do
    {
      input: {
        id: group.id.to_s
      }
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

  describe 'Group Leave' do
    context 'with valid id' do
      it 'attendee leaves the group' do
        expect do
          execute_and_parse_graphql_response query: leave_group_query, variables: variables, current_user: attendee
        end.
          to change(attendee.attenables, :count).by(-1)

        expect(parse_graphql_response['leaveGroup']).to match(
          status: "Success to Leave the #{group.name}",
          errors: []
        )
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { id: group.id })

          expect do
            execute_and_parse_graphql_response query: leave_group_query, variables: invalid_variables, current_user: attendee
          end.
            to change(attendee.attenables, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: leave_group_query, variables: variables, current_user: nil
        end.
          to change(attendee.attenables, :count).by(0)

        expect(parse_graphql_response['leaveGroup']).to match(
          status: nil,
          errors: ['Invalid user']
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: leave_group_query, variables: invalid_variables, current_user: attendee
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['leaveGroup']).to match(
          status: nil,
          errors: ["Couldn't find Group with 'id'=invalid"]
        )
      end
    end

    context 'not join the group yet' do
      it 'return error for none existed attendee' do
        attendee.attenables.delete_all

        expect do
          execute_and_parse_graphql_response query: leave_group_query, variables: variables, current_user: attendee
        end.
          to change(attendee.attenables, :count).by(0)

        expect(parse_graphql_response['leaveGroup']).to match(
          status: nil,
          errors: ["No record for attendee"]
        )
      end
    end
  end
end
