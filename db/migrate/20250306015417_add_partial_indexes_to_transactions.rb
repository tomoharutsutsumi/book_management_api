class AddPartialIndexesToTransactions < ActiveRecord::Migration[6.1]
  def change
    # Partial index for borrow transactions (transaction_type is borrow)
    add_index :transactions, :user_id, where: "transaction_type = 0", name: "index_transactions_on_user_id_for_borrow"

    # Partial index for return transactions (transaction_type is return)
    add_index :transactions, :user_id, where: "transaction_type = 1", name: "index_transactions_on_user_id_for_return"
  end
end
