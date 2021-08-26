module Resolvers
  class Groups < Resolvers::Base
    type [Types::Groups::GroupType], null: true

    description 'Fetch the public groups'
    argument :id, String, required: false, default_value: ''
    argument :range, String, required: false, default_value: ''
    def resolve(id:, range:)
      options = set_options params: { id: id, range: range }
      BaseService.call(:group, :fetch, options)
    end
  end
end
