require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:user) { create(:user, balance: 100.0) }
  let!(:book) { create(:book, title: "Test Book", status: :borrowed) }


  it "is valid with valid attributes" do
    transaction = Transaction.new(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0)
    expect(transaction).to be_valid
  end

  it "process_return! deducts fee and updates book status" do
    # Ensure the book is in a borrowed state
    book.update!(status: :borrowed)
    original_balance = user.balance
    transaction = Transaction.process_return!(user, book)
    expect(transaction).to be_persisted
    user.reload
    book.reload
    expect(user.balance).to eq(original_balance - Transaction::DEFAULT_BORROW_FEE)
    expect(book.available?).to be true
  end
end
