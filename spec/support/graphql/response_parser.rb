module GraphQL
  module ResponseParser

    attr_accessor :parse_graphql_response

    def execute_and_parse_graphql_response(query:, variables:nil, current_user: nil)
      params = {query: query, context: { current_user: current_user }}
      params.merge!({ variables: variables }) if variables.present?
      result = FocusSchema.execute(params)
      @parse_graphql_response = 
        if result.to_h.keys.include? "errors"
          result.to_h.except('data').with_indifferent_access
        else
          result.to_h.delete('data').with_indifferent_access
        end
    end

    def parse_response(original_response)
      JSON.parse(original_response).delete('data').with_indifferent_access
    end
  end
end
