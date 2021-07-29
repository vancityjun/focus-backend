class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :encrypted_password_iv, null: false
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
  end
end
