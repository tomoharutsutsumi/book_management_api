# frozen_string_literal: true

# Represents a Book in the library system.
# Manages attributes such as title and status (available or borrowed),
# and its association with transactions.
class Book < ApplicationRecord
  enum status: { available: 0, borrowed: 1 }

  has_many :transactions, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  def self.borrowed_by(user)
    # Using includes for transactions to enable eager loading.
    # Although currently the filtering is the same with or without includes,
    # this may be beneficial for future transaction-related optimizations.
    includes(:transactions)
      .where(transactions: { user_id: user.id, transaction_type: Transaction.transaction_types[:borrow] })
      .where(status: Book.statuses[:borrowed])
      .distinct
  end

  def income(start_date: nil, end_date: nil)
    s_date = start_date.present? ? Time.zone.parse(start_date) : Time.current.beginning_of_day
    e_date = end_date.present? ? Time.zone.parse(end_date) : Time.current.end_of_day

    transactions
      .where(transaction_type: Transaction.transaction_types[:return])
      .where(created_at: s_date..e_date)
      .sum(:fee_amount)
  end
end
