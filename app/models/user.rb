class User < ApplicationRecord
  validates :email, :password, :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  attr_encrypted :password, key: '11111111111111111111111111111111'

  before_save :lowercase_email, if: :email =~ /[A-Z]/

  def token
    JWT.encode(id.to_s, nil, 'none')
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def lowercase_email
    self.email = email.downcase
  end
end
