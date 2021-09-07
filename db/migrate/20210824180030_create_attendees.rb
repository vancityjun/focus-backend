class CreateAttendees < ActiveRecord::Migration[6.1]
  def change
    create_table :attendees do |t|
      t.integer :attendee_id
      t.integer :resource_id
      t.string :resource_type
      t.timestamps
    end
  end
end
