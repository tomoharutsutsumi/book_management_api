require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.create!(balance: 100.0) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "generates an account number before creation" do
    user = User.create!(balance: 50.0)
    expect(user.account_number).to be_present
  end

  it "requires a non-negative balance" do
    user = User.new(balance: -10)
    expect(user).not_to be_valid
  end

  describe "#report_for" do
    let(:user) { User.create!(balance: 100.0) }
    before do
      # Create a book and transactions for the current month
      book = Book.create!(title: "Test Book", status: :borrowed)
      Transaction.create!(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
      Transaction.create!(user: user, book: book, transaction_type: :return, fee_amount: 10.0, created_at: Time.current)
    end

    it "returns a monthly report" do
      report = user.report_for('monthly')
      expect(report[:borrowed_books_count]).to eq(1)
      expect(report[:amount_spent]).to eq(10.0)
    end

    it "raises an error for an invalid period" do
      expect { user.report_for('weekly') }.to raise_error(ArgumentError)
    end
  end
end
