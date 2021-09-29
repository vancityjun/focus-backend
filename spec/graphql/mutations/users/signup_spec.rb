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

  describe 'signup' do
    it 'with valid signup info' do
      response = execute_and_parse_graphql_response query: signup_query, variables: variables
      expect(response['signup']).to match(
        token: kind_of(String),
        errors: []
      )

      expect(User.count).to eq 1
      user = User.last
      expect(user).to have_attributes(
        email: variables[:email],
        first_name: variables[:userAttributes][:firstName],
        last_name: variables[:userAttributes][:lastName],
        gender: variables[:userAttributes][:gender],
        country: variables[:userAttributes][:country],
        city: variables[:userAttributes][:city],
        region: variables[:userAttributes][:region],
      )
    end

    context 'with invalid signup info' do
      it 'shorten password length' do
        response = execute_and_parse_graphql_response query: signup_query, variables: variables.merge(password: '1234')
        expect(response['signup']).to match(
          token: nil,
          errors: ['Password is too short (minimum is 8 characters)']
        )
      end

      it 'empty name value' do
        response = execute_and_parse_graphql_response query: signup_query, variables: variables.deep_merge(userAttributes: { firstName: '' })
        expect(response['signup']).to match(
          token: nil,
          errors: ["First name can't be blank"]
        )
      end
    end
  end
end
