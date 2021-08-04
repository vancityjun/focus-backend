class User < ApplicationRecord
  authenticates_with_sorcery!
  
  validates_presence_of :email, :password, :first_name, :last_name
  
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true , if: -> { new_record? || changes[:crypted_password] }

  before_save :lowercase_email, if: :email =~ /[A-Z]/

  def full_name
    "#{first_name} #{last_name}"
  end

  def for_token
    {
      user_id: id,
      user_name: full_name
    }
  end

  private

  def lowercase_email
    self.email = email.downcase
  end
end
