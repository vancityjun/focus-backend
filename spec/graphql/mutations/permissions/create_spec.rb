require 'rails_helper'

RSpec.describe Mutations::Permissions::Create, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:archived_group) { create :group, owner: owner, archived: true }
  let!(:attendee) { create :user, :attendee }
  let!(:archived_attendee) { create :user, :attendee, archived: true }

  let!(:variables) do
    {
      input: {
        userId: attendee.id.to_s,
        groupId: group.id.to_s,
      }
    }
  end
    
  let!(:add_permission_query) do
    <<-GQL
      mutation addPermission ($input: AddPermissionInput!) {
        addPermission (input: $input){
          status
          errors
        }
      }
    GQL
  end

  describe 'Permission Add' do
    context 'not have permission yet' do
      context 'with valid user and group' do
        it 'adds permission to attendee' do
          expect do
            execute_and_parse_graphql_response query: add_permission_query, variables: variables, current_user: owner
          end.
            to change(attendee.permissions, :count).by(1)

          expect(parse_graphql_response['addPermission']).to match(
            status: "Success to Add permission",
            errors: []
          )
        end
      end

      context 'with invalid variables' do
        context 'type miss matched' do
          it 'returns graphql errors' do
            invalid_variables = variables.deep_merge(input: { groupId: group.id })

            expect do
              execute_and_parse_graphql_response query: add_permission_query, variables: invalid_variables, current_user: owner
            end.
              to change(attendee.attenables, :count).by(0)

            expect(parse_graphql_response['errors']).to be_truthy
          end
        end
      end

      context 'with invalid current_user' do
        it 'returns error for invalid user' do
          expect do
            execute_and_parse_graphql_response query: add_permission_query, variables: variables, current_user: nil
          end.
            to change(attendee.attenables, :count).by(0)

          expect(parse_graphql_response['addPermission']).to match(
            status: nil,
            errors: ['Invalid user']
          )
        end
      end

      context 'with invalid user and group' do
        it 'returns errors' do
          invalid_variables = variables.deep_merge(input: { userId: archived_attendee.id.to_s, groupId: archived_group.id.to_s })

          expect do
            execute_and_parse_graphql_response query: add_permission_query, variables: invalid_variables, current_user: owner
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['addPermission']).to match(
            status: nil,
            errors: [
              "Group Unable to add permission.",
              "User Unable to add permission."
            ]
          )
        end
      end
    end

    context 'alread had permission' do
      it 'returns error for already added' do
        create :permission, user: attendee, group: group, created_by_user: owner

        expect do
          execute_and_parse_graphql_response query: add_permission_query, variables: variables, current_user: owner
        end.
          to change(attendee.attenables, :count).by(0)

        expect(parse_graphql_response['addPermission']).to match(
          status: nil,
          errors: ['User Already added.']
        )
      end
    end
  end
end
