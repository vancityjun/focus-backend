class Users::NewUser
  attr_reader :errors, :user_attributes

  def initialize(user_attributes)
    @user_attributes = user_attributes
    @errors = []
  end

  def create
    user = User.new user_attributes

    if user.save
      token = Jwt::TokenGenerator.issue_token user.for_token
      { token: token, errors: errors }
    else
      { token: 'Invalid', errors: user.errors.full_messages }
    end
  end
end
