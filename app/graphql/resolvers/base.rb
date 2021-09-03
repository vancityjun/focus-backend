module Resolvers
  class Base < GraphQL::Schema::Resolver
    def set_options(params:)
      Options.new current_user, params
    end

    def ready?(**args)
      if current_user.blank?
        raise GraphQL::ExecutionError, 'Invalid user'
      else
        true
      end
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
