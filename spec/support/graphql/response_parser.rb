module GraphQL
  module ResponseParser
    def execute_and_parse_graphql_response(query:, variables:)
      result = FocusSchema.execute(
        query,
        variables: { input: variables }
      )
      result.to_h.delete('data').with_indifferent_access
    end

    def parse_response(original_response)
      JSON.parse(original_response).delete('data').with_indifferent_access
    end
  end
end
