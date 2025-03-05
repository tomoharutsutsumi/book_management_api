class Transaction < ApplicationRecord
  DEFAULT_BORROW_FEE = 10.0

  belongs_to :user
  belongs_to :book

  enum transaction_type: { borrow: 0, return: 1 }

  validates :transaction_type, presence: true, inclusion: { in: transaction_types.keys }
  validates :fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.process_borrow!(user, book)
    t = self.new(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0)
    ActiveRecord::Base.transaction do
      book.borrowed!
      t.save!
      book.save!
    end
    t
  end

  def self.process_return!(user, book)
    t = self.new(user: user, book: book, transaction_type: :return, fee_amount: DEFAULT_BORROW_FEE)
    ActiveRecord::Base.transaction do
      user.update!(balance: user.balance - DEFAULT_BORROW_FEE)
      book.available!
      t.save!
    end
    t
  end
end
