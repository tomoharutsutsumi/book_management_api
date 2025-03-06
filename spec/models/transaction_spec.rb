# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it { should validate_presence_of(:transaction_type) }
    it { should define_enum_for(:transaction_type).with_values(borrow: 0, return: 1) }
    it { should validate_presence_of(:fee_amount) }
    it { should validate_numericality_of(:fee_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:transaction_type).with_values(borrow: 0, return: 1) }
  end

  describe '.process_borrow!' do
    let(:user) { create(:user, balance: 100.0) }
    let(:book) { create(:book, title: 'Test Book', status: :available) }

    it 'creates a borrow transaction and updates the book status to borrowed' do
      transaction = Transaction.process_borrow!(user, book)
      expect(transaction).to be_persisted
      expect(transaction.transaction_type).to eq('borrow')
      expect(transaction.fee_amount).to eq(0.0)
      expect(book.reload.status).to eq('borrowed')
    end
  end

  describe '.process_return!' do
    let(:user) { create(:user, balance: 100.0) }
    let(:book) { create(:book, title: 'Test Book', status: :borrowed) }

    it 'is valid with valid attributes' do
      transaction = Transaction.new(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0)
      expect(transaction).to be_valid
    end

    it 'creates a return transaction, deducts fee from user balance, and sets book to available' do
      transaction = Transaction.process_return!(user, book)
      expect(transaction).to be_persisted
      expect(transaction.transaction_type).to eq('return')
      expect(transaction.fee_amount).to eq(Transaction::DEFAULT_BORROW_FEE)
      expect(user.reload.balance).to eq(100.0 - Transaction::DEFAULT_BORROW_FEE)
      expect(book.reload.status).to eq('available')
    end
  end
end
