module Resolvers
	class Base < GraphQL::Schema::Resolver
		attr_reader :db_query

	protected

		def authorize_user
			return true if current_user.present?

			raise GraphQL::ExecutionError, "Can't find User"
		end

		def current_user
			context[:current_user]
		end

	end
end
