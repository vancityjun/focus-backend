require 'rails_helper'

RSpec.describe Mutations::Permissions::Delete, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:attendee) { create :user, :attendee }
  let!(:permission) { create :permission, user: attendee, group: group, created_by_user: owner }

  let!(:variables) do
    {
      input: {
        id: permission.id.to_s,
      }
    }
  end
    
  let!(:delete_permission_query) do
    <<-GQL
      mutation deletePermission ($input: DeletePermissionInput!) {
        deletePermission (input: $input){
          status
          errors
        }
      }
    GQL
  end

  describe 'Permission Delete' do
    context 'with valid id' do
      it 'deletes permission' do
        expect do
          execute_and_parse_graphql_response query: delete_permission_query, variables: variables, current_user: owner
        end.
          to change(attendee.permissions, :count).by(-1)

        expect(parse_graphql_response['deletePermission']).to match(
          status: 'Success to Delete permission',
          errors: []
        )
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { id: permission.id })

          expect do
            execute_and_parse_graphql_response query: delete_permission_query, variables: invalid_variables, current_user: owner
          end.
            to change(attendee.attenables, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: delete_permission_query, variables: variables, current_user: nil
        end.
          to change(attendee.attenables, :count).by(0)

        expect(parse_graphql_response['deletePermission']).to match(
          status: nil,
          errors: ['Invalid user']
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: delete_permission_query, variables: invalid_variables, current_user: owner
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['deletePermission']).to match(
          status: nil,
          errors: ["Couldn't find Permission with 'id'=invalid"]
        )
      end
    end
  end
end
