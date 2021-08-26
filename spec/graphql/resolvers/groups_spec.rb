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
  let!(:token) { generate_jwt_test_token(attendee) }

  let!(:query) do
    <<-GQL
      query($id: String!, $range: String!){
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
      let!(:variables) do
        {
          id: '',
          range: ''
        }
      end

      it 'fetches all active public groups' do
        post '/graphql', params: { query: query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response.status).to eq(200)

        parsed_response = parse_response response.body
        expect(parsed_response['groups']).to match_array([
          a_response_group(public_group_1),
          a_response_group(public_group_2),
        ])
      end
    end

    context 'with specific id' do
      let!(:variables) do
        {
          id: public_group_1.id.to_s,
          range: ''
        }
      end

      it 'fetches speific group in public' do
        post '/graphql', params: { query: query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response.status).to eq(200)

        parsed_response = parse_response response.body
        expect(parsed_response['groups']).to match_array([
          a_response_group(public_group_1),
        ])
      end
    end
  end

  describe 'range is "attended"' do
    context 'without specific id' do
      let!(:variables) do
        {
          id: '',
          range: 'attended'
        }
      end

      it 'fetches all attended groups' do
        post '/graphql', params: { query: query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response.status).to eq(200)

        parsed_response = parse_response response.body
        expect(parsed_response['groups']).to match_array([
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
        post '/graphql', params: { query: query, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response.status).to eq(200)

        parsed_response = parse_response response.body
        expect(parsed_response['groups']).to match_array([
          a_response_group(private_group),
        ])
      end
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
