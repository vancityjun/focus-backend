require 'rails_helper'

RSpec.describe Mutations::Users::Signup, type: :request do
  let!(:variables) do
    {
      password: '123456789',
      email: 'vince@example.com',
      userAttributes: {
        firstName: 'Vince',
        lastName: 'Yoon',
        gender: 'male',
        country: 'Canada',
        city: 'Vancouver',
        region: 'West'
      }
    }
  end

  let!(:signup_query) do
    <<-GQL
      mutation signup ($input: SignupUserInput!) {
        signup (input: $input){
          token
          errors
        }
      }
    GQL
  end

  describe 'User Signup' do
    context 'with valid variables' do
      it 'creates user' do
        expect do
          execute_and_parse_graphql_response query: signup_query, variables: variables
        end.
          to change(User, :count).by(1)

        expect(parse_graphql_response['signup']).to match(
          token: kind_of(String),
          errors: []
        )

        user = User.last
        expect(user).to have_attributes(
          email: variables[:input][:email],
          first_name: variables[:input][:userAttributes][:firstName],
          last_name: variables[:input][:userAttributes][:lastName],
          gender: variables[:input][:userAttributes][:gender],
          country: variables[:input][:userAttributes][:country],
          city: variables[:input][:userAttributes][:city],
          region: variables[:input][:userAttributes][:region],
        )
      end
    end

    context 'with invalid variables' do
      context 'type miss matched' do
        it 'returns graphql errors' do
          invalid_variables = variables.deep_merge(input: { password: 123456789 })

          expect do
            execute_and_parse_graphql_response query: signup_query, variables: invalid_variables
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['errors']).to be_truthy
        end
      end

      context 'validation not passed' do
        it 'returns error for length for value' do
          invalid_variables = variables.deep_merge(input: { password: '1234' })

          expect do
            execute_and_parse_graphql_response query: signup_query, variables: invalid_variables
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['signup']).to match(
            token: nil,
            errors: ['Password is too short (minimum is 8 characters)']
          )
        end

        it 'returns error for blank value' do
          invalid_variables = variables.deep_merge(input: { userAttributes: { firstName: '' } })

          expect do
            execute_and_parse_graphql_response query: signup_query, variables: invalid_variables
          end.
            to change(User, :count).by(0)

          expect(parse_graphql_response['signup']).to match(
            token: nil,
            errors: ["First name can't be blank"]
          )
        end
      end
    end
  end
end
