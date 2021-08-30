require 'rails_helper'

RSpec.describe Mutations::Groups::Create, type: :request do
  let!(:user) { create :user, :owner}
  let!(:token) { generate_jwt_test_token(user) }

  let!(:variables) do
    {
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

  describe 'with valid variables' do
    it 'creates the group' do
      expect do
        execute_and_parse_graphql_response query: create_group_query, variables: variables, current_user: user
      end.
        to change(user.groups, :count).by(1).
        and change(Attendee, :count).by(1)

      expect(parse_graphql_response['createGroup']['group']).to match(
        {
          id: user.groups.last.id.to_s,
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

      attenable = Attendee.order(:id).last
      expect(attenable.attendee).to eq user
    end
  end

  describe 'with invalid variables' do
    it 'returns errors when token does not existed' do
      post '/graphql', params: { query: create_group_query, variables: { input: variables }.to_json }
      parsed_response = parse_response response.body
      expect(parsed_response['createGroup']).to match(
        group: nil,
        errors: ['Invalid user']
      )
    end

    it 'returns errors when name is empty' do
      invalid_variables = variables.deep_merge(groupAttributes: { name: '' })

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
