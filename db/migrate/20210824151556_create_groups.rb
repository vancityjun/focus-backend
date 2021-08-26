class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :owner_id
      t.integer :slots
      t.string :country
      t.string :region
      t.string :city
      t.string :street_address
      t.string :post_code
      t.boolean :private, default: false
      t.boolean :archived, default: false
      t.datetime :archived_at
      t.timestamps
    end

    add_index :groups, :owner_id
  end
end
