class Group < ApplicationRecord
  include Archivable

  attr_accessor :manage_by_user

  belongs_to :owner, class_name: 'User'
  has_many :attenables, class_name: 'Attendee', as: :resource
  has_many :attendees, through: :attenables, source: :attendee
  has_many :permissions

  validates_presence_of :name, :description, :slots

  default_scope { joins(:owner).merge(User.active) }
  scope :find_public, -> { where(private: false)}

  before_save :has_permission, unless: :new_record?
  after_create :add_attendee

  def being_archived?
    changed.include?("archived") && archived?
  end

private
  def add_attendee
    attendee = Attendee.new resource: self, attendee: owner
    attendee.save
  end

  def has_permission
    allowed_user_ids = [owner_id]
    allowed_user_ids += permissions.map(&:user_id) unless being_archived?

    unless allowed_user_ids.include? manage_by_user.id
      errors.add :user, "Does not have permission."
      raise ActiveRecord::RecordInvalid.new self
    end
  end
end
