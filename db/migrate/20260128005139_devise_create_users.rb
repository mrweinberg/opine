# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Custom fields
      t.string :username, null: false
      t.string :display_name
      t.text :bio
      t.integer :role, default: 0, null: false  # enum: user=0, admin=1, superadmin=2

      ## OAuth
      t.string :provider
      t.string :uid

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :username,             unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, [ :provider, :uid ],     unique: true
  end
end
