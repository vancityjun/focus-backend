module Mutations
  class AuthorizedMutation < Mutations::BaseMutation
    def ready?(**args)
      return false, { errors: ['Invalid user'] } if current_user.blank? or current_user.id.to_s != args[:id]
        
      true
    end
  end
end
