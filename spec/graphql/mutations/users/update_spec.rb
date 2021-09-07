require 'rails_helper'

RSpec.describe Mutations::Users::Update, type: :request do
  let!(:user) { create :user }
  let!(:previous_user_attr) { user }

  let!(:variables) do
    {
      input: {
        id: user.id.to_s,
        userAttributes: {
          email: 'vince@example.com',
          firstName: 'Vince',
          lastName: 'Yoon',
          gender: 'male',
          country: 'Canada',
          city: 'Vancouver',
          region: 'West'
        }
      }
    }
  end
    
  let!(:update_user_query) do
    <<-GQL
      mutation updateUser ($input: UpdateUserInput!) {
        updateUser (input: $input){
          user {
            id,
            fullName,
            userAttributes{
              email,
              firstName,
              lastName,
              gender,
              country,
              city,
              region,
            }
          }
          errors
        }
      }
    GQL
  end

  describe 'User Update' do
    context 'with valid variables' do
      it 'updates user attributes' do
        expect do
          execute_and_parse_graphql_response query: update_user_query, variables: variables, current_user: user
        end.
          to change(User, :count).by(0).
          and change { user.reload.email }.from(previous_user_attr.email).to(variables[:input][:userAttributes][:email]).
          and change { user.first_name }.from(previous_user_attr.first_name).to(variables[:input][:userAttributes][:firstName]).
          and change { user.last_name }.from(previous_user_attr.last_name).to(variables[:input][:userAttributes][:lastName])


        expect(parse_graphql_response['updateUser']['user']).to match(
          {
            id: user.id.to_s,
            userAttributes: {
              email: variables[:input][:userAttributes][:email],
              firstName: variables[:input][:userAttributes][:firstName],
              lastName: variables[:input][:userAttributes][:lastName],
              gender: variables[:input][:userAttributes][:gender],
              country: variables[:input][:userAttributes][:country],
              region: variables[:input][:userAttributes][:region],
              city: variables[:input][:userAttributes][:city],
            },
            fullName: "#{variables[:input][:userAttributes][:firstName]} #{variables[:input][:userAttributes][:lastName]}"
          }.with_indifferent_access
        )
      end

      it 'updates user password' do
        variables = {
          input: {
            id: user.id.to_s,
            password: '87654321',
          }
        }

        execute_and_parse_graphql_response query: update_user_query, variables: variables, current_user: user

        user.reload
        expect(Sorcery::CryptoProviders::BCrypt.matches? user.crypted_password, '87654321', user.salt).to be true
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { password: 123456789 })

          expect do
            execute_and_parse_graphql_response query: update_user_query, variables: invalid_variables, current_user: user
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end

      context 'validation not passed' do
        it 'returns error for length for value' do
          invalid_variables = {
            input: {
              id: user.id.to_s,
              password: '1234',
            }
          }

          expect do
            execute_and_parse_graphql_response query: update_user_query, variables: invalid_variables, current_user: user
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['updateUser']).to match(
            user: nil,
            errors: ['Password is too short (minimum is 8 characters)']
          )
        end

        it 'returns error for blank value' do
          invalid_variables = variables.deep_merge(input: { userAttributes: { firstName: '' } })

          expect do
            execute_and_parse_graphql_response query: update_user_query, variables: invalid_variables, current_user: user
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['updateUser']).to match(
            user: nil,
            errors: ["First name can't be blank"]
          )
        end
      end
    end

    context 'with invalid current_user' do
      it 'returns error for invalid user' do
        expect do
          execute_and_parse_graphql_response query: update_user_query, variables: variables, current_user: nil
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['updateUser']).to match(
          user: nil,
          errors: ['Invalid user']
        )
      end
    end

    context 'with invalid id' do
      it 'returns error for none existed record' do
        invalid_variables = variables.deep_merge(input: { id: 'invalid' })

        expect do
          execute_and_parse_graphql_response query: update_user_query, variables: invalid_variables, current_user: user
        end.
          to change(User, :count).by(0)

        expect(parse_graphql_response['updateUser']).to match(
          user: nil,
          errors: ["Couldn't find User with 'id'=invalid"]
        )
      end
    end
  end
end
