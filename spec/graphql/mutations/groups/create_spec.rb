require 'rails_helper'

RSpec.describe Mutations::Groups::Create, type: :request do
  let!(:user) { create :user, :owner}
  let!(:variables) do
    {
      input: {
        groupAttributes: {
          name: 'Group 1',
          description: 'Group 1 Test',
          slots: 5,
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
    
  let!(:create_group_query) do
    <<-GQL
      mutation createGroup ($input: CreateGroupInput!) {
        createGroup (input: $input){
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

  describe 'Group Create' do
    context 'with valid variables' do
      it 'creates the group' do
        expect do
          execute_and_parse_graphql_response query: create_group_query, variables: variables, current_user: user
        end.
          to change(user.groups, :count).by(1).
          and change(Attendee, :count).by(1)

        expect(parse_graphql_response['createGroup']['group']).to match(
          {
            id: user.groups.last.id.to_s,
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

        attenable = Attendee.order(:id).last
        expect(attenable.attendee).to eq user
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          expect do
            execute_and_parse_graphql_response query: create_group_query, current_user: user
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end

      context 'validation not passed' do
        it 'returns error for blank value' do
          invalid_variables = variables.deep_merge(input: { groupAttributes: { name: '' } })

          expect do
            execute_and_parse_graphql_response query: create_group_query, variables: invalid_variables, current_user: user
          end.
            to change(user.groups, :count).by(0).
            and change(Attendee, :count).by(0)

          expect(parse_graphql_response['createGroup']).to match(
            group: nil,
            errors: ["Name can't be blank"]
          )
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: create_group_query, variables: variables, current_user: nil
        end.
          to change(user.groups, :count).by(0)

        expect(parse_graphql_response['createGroup']).to match(
          group: nil,
          errors: ['Invalid user']
        )
      end
    end
  end
end
