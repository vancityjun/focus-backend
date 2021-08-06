class SorceryCore < ActiveRecord::Migration[6.1]
  def change
    drop_table(:users, if_exists: true)

    create_table :users do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :gender
      t.string :country
      t.string :region
      t.string :city
      t.boolean :archived
      t.datetime :date_of_birth
      t.datetime :archived_at
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
