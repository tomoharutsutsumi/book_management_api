# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :account_number, null: false
      t.decimal :balance, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps null: false
    end

    add_index :users, :account_number,       unique: true
  end
end
