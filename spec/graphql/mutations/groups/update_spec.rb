require 'rails_helper'

RSpec.describe Mutations::Groups::Update, type: :request do
  let!(:user) { create :user, :owner }
  let!(:token) { generate_jwt_test_token(user) }
  let!(:group) { create :group, owner: user }
  let!(:previous_group_attr) { group }

  let!(:variables) do
    {
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

  describe 'with valid variables' do
    it 'updates the group' do
      expect do
        execute_and_parse_graphql_response query: update_group_query, variables: variables, current_user: user
      end.
        to change(user.groups, :count).by(0).
        and change(Attendee, :count).by(0).
        and change { group.reload.name }.from(previous_group_attr.name).to(variables[:groupAttributes][:name]).
        and change { group.description }.from(previous_group_attr.description).to(variables[:groupAttributes][:description]).
        and change { group.slots }.from(previous_group_attr.slots).to(variables[:groupAttributes][:slots])

      expect(parse_graphql_response['updateGroup']['group']).to match(
        {
          id: group.id.to_s,
          name: variables[:groupAttributes][:name],
          description: variables[:groupAttributes][:description],
          slots: variables[:groupAttributes][:slots],
          country: variables[:groupAttributes][:country],
          region: variables[:groupAttributes][:region],
          city: variables[:groupAttributes][:city],
          streetAddress: variables[:groupAttributes][:streetAddress],
          postCode: variables[:groupAttributes][:postCode],
          private: variables[:groupAttributes][:private],
          attend: true
        }.with_indifferent_access
      )
    end
  end

  describe 'with invalid variables' do
    it 'returns errors when token does not existed' do
      post '/graphql', params: { query: update_group_query, variables: { input: variables }.to_json }
      parsed_response = parse_response response.body
      expect(parsed_response['updateGroup']).to match(
        group: nil,
        errors: ['Invalid user']
      )
    end

    it 'returns errors when description is empty' do
      invalid_variables = variables.deep_merge(groupAttributes: { description: '' })

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
