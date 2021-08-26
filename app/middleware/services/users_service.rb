module Services
  class UsersService < BaseService

    def create
      user = User.new params
      if user.save
        token = Jwt::TokenGenerator.issue_token user.for_token
        { token: token, errors: [] }
      else
        { token: nil, errors: user.errors.full_messages }
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
        { status: 'Success to Delete User', errors: [] }
      else
        { status: nil, errors: object.errors.full_messages }
      end
    end

    def login
      user = User.authenticate params[:email], params[:password]

      if user.blank?
        { token: nil, errors: ['Invalid email or password.'] }
      elsif user.archived?
        { token: nil, errors: ['This User is deactivated.'] }
      else
         token = Jwt::TokenGenerator.issue_token user.for_token
        { token: token, errors: [] }
      end
    end
  end
end
