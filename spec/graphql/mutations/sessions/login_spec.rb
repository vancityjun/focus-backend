require 'rails_helper'

RSpec.describe Mutations::Sessions::Login, type: :request do
	let!(:user) { create :user }
  let!(:variables) do 
    {
      email: 'jun@example.com',
      password: '12345678'
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

  describe 'login' do
  	it 'with valid login info' do
      response = excute_and_parse_graphql_response query: login_query, variables: variables
      expect(response['login']).to match(
        token: kind_of(String),
        errors: []
      )
  	end

    context 'with invalid login info' do
      it 'with invalid email' do
        response = excute_and_parse_graphql_response query: login_query, variables: variables.merge(email: 'invalid@example.com')
        expect(response['login']).to match(
          token: 'Invalid',
          errors: ['Invalid email or password']
        )
      end

      it 'with invalid password' do
        response = excute_and_parse_graphql_response query: login_query, variables: variables.merge(password: '87654321')
        expect(response['login']).to match(
          token: 'Invalid',
          errors: ['Invalid email or password']
        )
      end
    end
  end
 end