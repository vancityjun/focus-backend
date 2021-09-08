require 'rails_helper'

RSpec.describe Mutations::Users::Delete, type: :request do
  let!(:user) { create :user }
  let!(:previous_user_attr) { user }
  
  let!(:variables) do
    {
      input: {
        id: user.id.to_s
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

  describe 'User Delete' do
    context 'with valid id' do
      freeze_time! { Time.zone.parse('2021-08-17 09:00') }

      it 'archives user' do
        expect do
          execute_and_parse_graphql_response query: delete_user_query, variables: variables, current_user: user
        end.
          to change(User, :count).by(0).
          and change { user.reload.archived }.from(nil).to(true).
          and change { user.archived_at }.from(nil).to(now)

        expect(parse_graphql_response['deleteUser']).to match(
          status: 'Success to Delete User',
          errors: []
        )
      end
    end

    context 'if association recods existed' do
      let!(:owner) { create :user, :owner }
      let!(:group) { create :group, owner: owner }
      let!(:attenable) { create :attendee, attendee: user, resource: group }
      let!(:permission) { create :permission, user: user, group: group, created_by_user: owner }

      it 'destroys association records' do
        expect do
        execute_and_parse_graphql_response query: delete_user_query, variables: variables, current_user: user
      end.
        to change(User, :count).by(0).
        and change(user.attenables, :count).by(-1).
        and change(user.permissions, :count).by(-1)

      expect(parse_graphql_response['deleteUser']).to match(
        status: 'Success to Delete User',
        errors: []
      )
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { id: user.id })

          expect do
            execute_and_parse_graphql_response query: delete_user_query, variables: invalid_variables, current_user: user
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: delete_user_query, variables: variables, current_user: nil
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['deleteUser']).to match(
          status: nil,
          errors: ['Invalid user']
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: delete_user_query, variables: invalid_variables, current_user: user
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['deleteUser']).to match(
          status: nil,
          errors: ["Couldn't find User with 'id'=invalid"]
        )
      end
    end
  end
end
