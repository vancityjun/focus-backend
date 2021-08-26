class Attendee < ApplicationRecord

  belongs_to :resource, polymorphic: true
  belongs_to :attendee, class_name: 'User'

  validate :valid_attendee

  def valid_attendee
    errors.add :base, "Already Join the #{resource_type}" if existed_attendee?
  end

private

  def existed_attendee?
    Attendee.where(resource_id: resource_id, resource_type: resource_type, attendee_id: attendee_id).exists?
  end
end
