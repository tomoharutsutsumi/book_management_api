class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :transaction_type, null: false
      t.decimal :fee_amount, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end
