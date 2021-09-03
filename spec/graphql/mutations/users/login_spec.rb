require 'rails_helper'

RSpec.describe Mutations::Users::Login, type: :request do
  let!(:user) { create :user }
  let!(:variables) do
    {
      input: {
        email: 'jun@example.com',
        password: '12345678'
      }
    }
  end

  let!(:login_query) do
    <<-GQL
      mutation login ($input: LoginUserInput!) {
        login (input: $input){
          token
          errors
        }
      }
    GQL
  end

  describe 'User Login' do
    it 'with valid login info' do
      execute_and_parse_graphql_response query: login_query, variables: variables

      expect(parse_graphql_response['login']).to match(
        token: kind_of(String),
        errors: []
      )
    end

    context 'with invalid login info' do
      it 'with invalid email' do
        invalid_variables = variables.deep_merge(input: { email: 'invalid@example.com' })

        response = execute_and_parse_graphql_response query: login_query, variables: invalid_variables
        expect(parse_graphql_response['login']).to match(
          token: nil,
          errors: ['Invalid email or password.']
        )
      end

      it 'with invalid password' do
        invalid_variables = variables.deep_merge(input: { password: '87654321' })

        response = execute_and_parse_graphql_response query: login_query, variables: invalid_variables
        expect(parse_graphql_response['login']).to match(
          token: nil,
          errors: ['Invalid email or password.']
        )
      end
    end
  end
end
