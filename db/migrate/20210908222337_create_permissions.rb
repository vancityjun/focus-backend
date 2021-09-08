class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :created_by_user_id
      t.timestamps
    end
  end
end
