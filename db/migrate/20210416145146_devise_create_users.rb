# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string    :email,                 null: false
      t.string    :name,                  null: false
      t.integer   :employee_number,       null: false
      t.string    :uid,                   null: true,   default: nil
      t.string    :remember_token,        null: true,   default: nil
      t.datetime  :remember_created_at,   null: true,   default: nil
      t.integer   :sign_in_count,         null: false,  default: 0
      t.datetime  :current_sign_in_at,    null: true,   default: nil
      t.datetime  :last_sign_in_at,       null: true,   default: nil
      t.string    :current_sign_in_ip,    null: true,   default: nil
      t.string    :last_sign_in_ip,       null: true,   default: nil
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :employee_number, unique: true
  end
end