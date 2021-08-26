module Resolvers
  class Base < GraphQL::Schema::Resolver
    attr_reader :db_query

    def set_options(params:)
      Options.new current_user, params
    end
    
  protected
    def authorize_user
      return true if current_user.present?

      raise GraphQL::ExecutionError, "Can't find User"
    end

    def current_user
      context[:current_user]
    end

    Options = Struct.new(:current_user, :params)
  end
end
