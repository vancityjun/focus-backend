require 'rails_helper'

RSpec.describe Mutations::Groups::Update, type: :request do
  let!(:user) { create :user, :owner }
  let!(:group) { create :group, owner: user }
  let!(:previous_group_attr) { group }

  let!(:variables) do
    {
      input: {
        id: group.id.to_s,
        groupAttributes: {
          name: 'Group 1',
          description: 'Group 1 Test',
          slots: 10,
          country: 'Canada',
          region: 'West',
          city: 'Vancouver',
          streetAddress: 'Fake Street',
          postCode: '123 456',
          private: false
        }
      }
    }
  end
    
  let!(:update_group_query) do
    <<-GQL
      mutation updateGroup ($input: UpdateGroupInput!) {
        updateGroup (input: $input){
          group {
            id,
            name,
            description,
            slots,
            country,
            region,
            city,
            streetAddress,
            postCode,
            private,
            attend
          }
          errors
        }
      }
    GQL
  end

  describe 'Group Update' do
    context 'with valid variables' do
      it 'updates group attributes' do
        expect do
          execute_and_parse_graphql_response query: update_group_query, variables: variables, current_user: user
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0).
          and change { group.reload.name }.from(previous_group_attr.name).to(variables[:input][:groupAttributes][:name]).
          and change { group.description }.from(previous_group_attr.description).to(variables[:input][:groupAttributes][:description]).
          and change { group.slots }.from(previous_group_attr.slots).to(variables[:input][:groupAttributes][:slots])

        expect(parse_graphql_response['updateGroup']['group']).to match(
          {
            id: group.id.to_s,
            name: variables[:input][:groupAttributes][:name],
            description: variables[:input][:groupAttributes][:description],
            slots: variables[:input][:groupAttributes][:slots],
            country: variables[:input][:groupAttributes][:country],
            region: variables[:input][:groupAttributes][:region],
            city: variables[:input][:groupAttributes][:city],
            streetAddress: variables[:input][:groupAttributes][:streetAddress],
            postCode: variables[:input][:groupAttributes][:postCode],
            private: variables[:input][:groupAttributes][:private],
            attend: true
          }.with_indifferent_access
        )
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { groupAttributes: { slots: '10' } })

          expect do
            execute_and_parse_graphql_response query: update_group_query, variables: invalid_variables, current_user: user
          end.
            to change(user.groups, :count).by(0).
            and change(Attendee, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end

      context 'validation not passed' do
        it 'returns error for blank value' do
          invalid_variables = variables.deep_merge(input: { groupAttributes: { description: '' } })

          expect do
            execute_and_parse_graphql_response query: update_group_query, variables: invalid_variables, current_user: user
          end.
            to change(user.groups, :count).by(0).
            and change(Attendee, :count).by(0)

          expect(parse_graphql_response['updateGroup']).to match(
            group: nil,
            errors: ["Description can't be blank"]
          )
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: update_group_query, variables: variables, current_user: nil
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0)

        expect(parse_graphql_response['updateGroup']).to match(
          group: nil,
          errors: ['Invalid user']
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: update_group_query, variables: invalid_variables, current_user: user
        end.
          to change(user.groups, :count).by(0).
          and change(Attendee, :count).by(0)

        expect(parse_graphql_response['updateGroup']).to match(
          group: nil,
          errors: ["Couldn't find Group with 'id'=invalid"]
        )
      end
    end
  end
end
