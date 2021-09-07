module Mutations
  class AuthorizedMutation < Mutations::BaseMutation
    def ready?(**args)
      return false, { errors: ['Invalid user'] } if current_user.blank?
        
      true
    end
  end
end
