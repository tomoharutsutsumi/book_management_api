# frozen_string_literal: true

# Represents a User in the library system.
# Manages user-specific attributes such as account number and balance,
# and tracks the user's associated transactions.
# Provides methods to generate account reports over specified time periods.
class User < ApplicationRecord
  before_validation :generate_account_number, on: :create

  has_many :transactions, dependent: :destroy

  validates :account_number, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def report_for(period)
    start_date, end_date = period_range(period)

    {
      period: period,
      start_date: start_date,
      end_date: end_date,
      borrowed_books_count: borrowed_books_count_in(start_date, end_date),
      amount_spent: amount_spent_in(start_date, end_date)
    }
  end

  private

  def period_range(period)
    # This case statement handles only 'monthly' and 'annual' periods, which is sufficient for specification.
    # If additional period types are required or the period logic becomes more complex,
    # consider refactoring using a hash mapping for improved maintainability and extensibility.
    case period
    when 'monthly'
      [Time.current.beginning_of_month, Time.current.end_of_month]
    when 'annual'
      [Time.current.beginning_of_year, Time.current.end_of_year]
    else
      raise ArgumentError, "Invalid period parameter. Use 'monthly' or 'annual'."
    end
  end

  def borrowed_books_count_in(start_date, end_date)
    transactions
      .where(transaction_type: Transaction.transaction_types[:borrow], created_at: start_date..end_date)
      .count
  end

  def amount_spent_in(start_date, end_date)
    transactions
      .where(transaction_type: Transaction.transaction_types[:return], created_at: start_date..end_date)
      .sum(:fee_amount)
      .to_f
  end

  def generate_account_number
    self.account_number ||= loop do
      token = SecureRandom.hex(5)
      break token unless User.exists?(account_number: token)
    end
  end
end
