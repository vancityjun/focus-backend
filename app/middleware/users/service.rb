module Users
  class Service < BaseService

    def create
      user = User.new params
      if user.save
        token = Jwt::TokenGenerator.issue_token user.for_token
        { token: token, errors: [] }
      else
        { token: 'Invalid', errors: user.errors.full_messages }
      end
    end

    def update
      if object.update params
        { user: object, errors: [] }
      else
        { user: nil, errors: object.errors.full_messages }
      end
    end

    def delete
      if object.archive
        { status: 'Success deleting user', errors: [] }
      else
        { status: nil, errors: object.errors.full_messages }
      end
    end
  end
end
