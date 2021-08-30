module GraphQL
  module ResponseParser

    attr_accessor :parse_graphql_response

    def execute_and_parse_graphql_response(query:, variables:, current_user: nil)
      result = FocusSchema.execute(
        query,
        variables: { input: variables },
        context: { current_user: current_user }
      )
      @parse_graphql_response = result.to_h.delete('data').with_indifferent_access
    end

    def parse_response(original_response)
      JSON.parse(original_response).delete('data').with_indifferent_access
    end
  end
end
