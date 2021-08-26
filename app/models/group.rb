class Group < ApplicationRecord
  include Archivable

  belongs_to :owner, class_name: 'User'
  has_many :attenables, class_name: 'Attendee', as: :resource
  has_many :attendees, through: :attenables, source: :attendee

  validates_presence_of :name, :description, :slots

  scope :find_public, -> { where(private: false)}

  after_create :add_attendee
  after_archive :destroy_attenables

private
  def add_attendee
    attendee = Attendee.new resource: self, attendee: owner
    attendee.save
  end

  def destroy_attenables
    return if archived == false
    
    attenables.each do |attenable|
      attenable.destroy!
    end
  end
end
