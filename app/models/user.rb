class User < ApplicationRecord
  before_validation :generate_account_number, on: :create

  has_many :transactions, dependent: :destroy

  validates :account_number, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def report_for(period)
    # This case statement handles only 'monthly' and 'annual' periods, which is sufficient for specification.
    # If additional period types are required or the period logic becomes more complex,
    # consider refactoring using a hash mapping for improved maintainability and extensibility.
    case period
    when 'monthly'
      s_date = Time.current.beginning_of_month
      e_date = Time.current.end_of_month
    when 'annual'
      s_date = Time.current.beginning_of_year
      e_date = Time.current.end_of_year
    else
      raise ArgumentError, "Invalid period parameter. Use 'monthly' or 'annual'."
    end

    borrowed_books_count = transactions
                      .where(transaction_type: Transaction.transaction_types[:borrow], created_at: s_date..e_date)
                      .count

    amount_spent = transactions
                   .where(transaction_type: Transaction.transaction_types[:return], created_at: s_date..e_date)
                   .sum(:fee_amount)
                   .to_f

    {
      period: period,
      start_date: s_date,
      end_date: e_date,
      borrowed_books_count: borrowed_books_count,
      amount_spent: amount_spent
    }
  end

  private

  def generate_account_number
    self.account_number ||= loop do
      token = SecureRandom.hex(5)
      break token unless User.exists?(account_number: token)
    end
  end
end
