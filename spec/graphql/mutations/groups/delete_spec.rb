require 'rails_helper'

RSpec.describe Mutations::Groups::Delete, type: :request do
  let!(:user) { create :user, :owner }
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

  describe 'Group Delete' do
    context 'with valid id' do
      freeze_time! { Time.zone.parse('2021-08-17 09:00') }

      it 'archives user' do
        expect do
          execute_and_parse_graphql_response query: delete_group_query, variables: variables, current_user: user
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0).
          and change { group.reload.archived }.from(false).to(true).
          and change { group.archived_at }.from(nil).to(now)

        expect(parse_graphql_response['deleteGroup']).to match(
          status: 'Success to Delete Group',
          errors: []
        )

        attenable = Attendee.order(:id).last
        expect(attenable.attendee).to eq user
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { id: group.id })

          expect do
            execute_and_parse_graphql_response query: delete_group_query, variables: invalid_variables, current_user: user
          end.
            to change(user.groups, :count).by(0).
            and change(Attendee, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: delete_group_query, variables: variables, current_user: nil
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0)

        expect(parse_graphql_response['deleteGroup']).to match(
          status: nil,
          errors: ["Invalid user"]
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: delete_group_query, variables: invalid_variables, current_user: user
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0)

        expect(parse_graphql_response['deleteGroup']).to match(
          status: nil,
          errors: ["Couldn't find Group with 'id'=invalid [WHERE (users.archived IS NULL OR users.archived IS false)]"]
        )
      end
    end

    context 'if group owner is not current_user' do
      let!(:attendee) { create :user, :attendee }
      let!(:permission) { create :permission, user: attendee, group: group, created_by_user: user }

      it 'returns error for permission' do
        expect do
          execute_and_parse_graphql_response query: delete_group_query, variables: variables, current_user: attendee
        end.
          to change(Group, :count).by(0)

        expect(parse_graphql_response['deleteGroup']).to match(
          status: nil,
          errors: ["User Does not have permission."]
        )
      end
    end
  end
end
