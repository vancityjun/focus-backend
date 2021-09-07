class User < ApplicationRecord
  include Archivable

  authenticates_with_sorcery!
  
  has_many :groups, foreign_key: :owner_id
  has_many :attenables, class_name: 'Attendee', foreign_key: :attendee_id
  has_many :attended_groups, through: :attenables, source: :resource, source_type: 'Group' 

  validates_presence_of :email, :first_name, :last_name
  validates_presence_of :password, if: :password_required?
  
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true , if: -> { new_record? || changes[:crypted_password] }

  before_save :lowercase_email, if: :email =~ /[A-Z]/
  after_archive :destroy_attenables

  def full_name
    "#{first_name} #{last_name}"
  end

  def for_token
    {
      user_id: id,
      user_email: email
    }
  end

private
  def lowercase_email
    self.email = email.downcase
  end

  def password_required?
    !persisted? || !password.nil?
  end

  def destroy_attenables
    return if archived == false
    
    attenables.each do |attenable|
      attenable.destroy!
    end
  end
end
