class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum transaction_type: { borrow: 0, return: 1 }

  validates :transaction_type, presence: true, inclusion: { in: transaction_types.keys }
  validates :fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
