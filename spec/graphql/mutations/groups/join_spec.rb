require 'rails_helper'

RSpec.describe Mutations::Groups::Join, type: :request do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:attendee) { create :user, :attendee }

  let!(:variables) do
    {
      input: {
        id: group.id.to_s
      }
    }
  end
    
  let!(:join_group_query) do
    <<-GQL
      mutation joinGroup ($input: JoinGroupInput!) {
        joinGroup (input: $input){
          status
          errors
        }
      }
    GQL
  end

  describe 'Group Join' do
    context 'not join the group yet' do
      context 'with valid id' do
        it 'attendee joins the group' do
          expect do
            execute_and_parse_graphql_response query: join_group_query, variables: variables, current_user: attendee
          end.
            to change(attendee.attenables, :count).by(1)

          expect(parse_graphql_response['joinGroup']).to match(
            status: "Success to Join the #{group.name}",
            errors: []
          )

          attenable = Attendee.order(:id).last
          expect(attenable.attendee).to eq attendee
        end
      end

      context 'with invalid variables' do
        context 'type miss matched' do
          it 'returns graphql errors' do
            invalid_variables = variables.deep_merge(input: { id: group.id })

            expect do
              execute_and_parse_graphql_response query: join_group_query, variables: invalid_variables, current_user: attendee
            end.
              to change(attendee.attenables, :count).by(0)

            expect(parse_graphql_response['errors']).to be_truthy
          end
        end
      end

      context 'with invalid current_user' do
        it 'returns error for invalid user' do
          expect do
            execute_and_parse_graphql_response query: join_group_query, variables: variables, current_user: nil
          end.
            to change(attendee.attenables, :count).by(0)

          expect(parse_graphql_response['joinGroup']).to match(
            status: nil,
            errors: ['Invalid user']
          )
        end
      end

      context 'with invalid id' do
        it 'returns error for none existed record' do
          invalid_variables = variables.deep_merge(input: { id: 'invalid' })

          expect do
            execute_and_parse_graphql_response query: join_group_query, variables: invalid_variables, current_user: attendee
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['joinGroup']).to match(
            status: nil,
            errors: ["Couldn't find Group with 'id'=invalid"]
          )
        end
      end
    end

    context 'alread join the group' do
      it 'returns error for already joined' do
        create :attendee, attendee: attendee, resource: group

        expect do
          execute_and_parse_graphql_response query: join_group_query, variables: variables, current_user: attendee
        end.
          to change(attendee.attenables, :count).by(0)

        expect(parse_graphql_response['joinGroup']).to match(
          status: nil,
          errors: ['Already Join the Group']
        )
      end
    end
  end
end
