module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def current_user
      context[:current_user]
    end

    def set_options(params:)
      Options.new current_user, params
    end

  private
    Options = Struct.new(:current_user, :params)
  end
end
