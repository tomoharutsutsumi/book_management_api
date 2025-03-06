# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:status) }
  it { should define_enum_for(:status).with_values(available: 0, borrowed: 1) }

  it { should have_many(:transactions).dependent(:destroy) }

  it { should define_enum_for(:status).with_values(available: 0, borrowed: 1) }

  describe '#income' do
    let(:book) { create(:book, title: 'Test Book', status: :borrowed) }
    let(:user) { create(:user, balance: 100.0) }

    before do
      create(:transaction, book: book, user: user, transaction_type: :return, fee_amount: 10.0,
                           created_at: Time.current)
      create(:transaction, book: book, user: user, transaction_type: :return, fee_amount: 5.0, created_at: Time.current)
      create(:transaction, book: book, user: user, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
    end

    it 'calculates the total income from return transactions' do
      expect(book.income).to eq(15.0)
    end

    context 'when a date range is provided' do
      let(:start_date) { (Time.current - 1.day).to_s }
      let(:end_date) { (Time.current + 1.day).to_s }

      it 'calculates income within the given date range' do
        expect(book.income(start_date: start_date, end_date: end_date)).to eq(15.0)
      end
    end
  end

  it 'is valid with a title' do
    book = Book.new(title: 'Test Book', status: :available)
    expect(book).to be_valid
  end

  it 'is invalid without a title' do
    book = Book.new(status: :available)
    expect(book).not_to be_valid
  end

  it 'properly handles status enum' do
    book = Book.create!(title: 'Test Book', status: :available)
    expect(book.available?).to be true
    book.borrowed!
    expect(book.borrowed?).to be true
  end
end
