require 'rails_helper'

RSpec.describe Resolvers::Groups, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:public_group_1) { create :group, owner: owner }
  let!(:public_group_2) { create :group, owner: owner }
  let!(:private_group) { create :group, owner: owner, private: true }
  let!(:archive_group) { create :group, owner: owner, archived: true }
  
  let!(:attendee) { create :user, :attendee }
  let!(:attenable_1) { create :attendee, attendee: attendee, resource: public_group_1 }
  let!(:attenable_2) { create :attendee, attendee: attendee, resource: private_group }

  let!(:query) do
    <<-GQL
      query($id: String, $range: String){
        groups (id: $id, range: $range){
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
      }
    GQL
  end

  describe 'range is empty' do
    context 'without specific id' do
      it 'fetches all active public groups' do
        execute_and_parse_graphql_response query: query, current_user: attendee
        expect(parse_graphql_response['groups']).to match_array([
          a_response_group(public_group_1),
          a_response_group(public_group_2),
        ])
      end
    end

    context 'with specific id' do
      let!(:variables) do
        {
          id: public_group_1.id.to_s
        }
      end

      it 'fetches speific group in public' do
        execute_and_parse_graphql_response query: query, variables: variables, current_user: attendee
        expect(parse_graphql_response['groups']).to match_array([
          a_response_group(public_group_1),
        ])
      end
    end

    context 'with invalid id' do
      let!(:variables) do
        {
          id: '0'
        }
      end

      it 'returns empty array' do
        execute_and_parse_graphql_response query: query, variables: variables, current_user: attendee
        expect(parse_graphql_response['groups']).to eq []
      end
    end
  end

  describe 'range is "attended"' do
    context 'without specific id' do
      let!(:variables) do
        {
          range: 'attended'
        }
      end

      it 'fetches all attended groups' do
        execute_and_parse_graphql_response query: query, variables: variables, current_user: attendee
        expect(parse_graphql_response['groups']).to match_array([
          a_response_group(public_group_1),
          a_response_group(private_group),
        ])
      end
    end

    context 'with specific id' do
      let!(:variables) do
        {
          id: private_group.id.to_s,
          range: 'attended'
        }
      end

      it 'fetches speific group in attended' do
        execute_and_parse_graphql_response query: query, variables: variables, current_user: attendee
        expect(parse_graphql_response['groups']).to match_array([
          a_response_group(private_group),
        ])
      end
    end

    context 'with specific id' do
      let!(:variables) do
        {
          id: '0',
          range: 'attended'
        }
      end

      it 'returns empty array' do
        execute_and_parse_graphql_response query: query, variables: variables, current_user: attendee
        expect(parse_graphql_response['groups']).to eq []
      end
    end
  end

  describe 'current_user is invalid' do
    it 'returns errors' do
      execute_and_parse_graphql_response query: query, current_user: nil
      expect(parse_graphql_response['errors']).to be_truthy
    end
  end

  def a_response_group(group)
    {
      id: group.id.to_s,
      name: group.name,
      description: group.description,
      slots: group.slots,
      country: group.country,
      region: group.region,
      city: group.city,
      streetAddress: group.street_address,
      postCode: group.post_code,
      private: group.private?,
      attend: attend?(group.attenables)
    }.with_indifferent_access
  end

  def attend?(attenables)
    attenables.where(attendee: attendee).exists?
  end
end
