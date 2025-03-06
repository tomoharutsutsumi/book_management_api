# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }
    it { should validate_presence_of(:account_number) }
    it { should validate_uniqueness_of(:account_number) }
    it { should validate_presence_of(:balance) }
    it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe 'callbacks' do
    let!(:valid_user) { create(:user, balance: 100.0) }
    it 'is valid with valid attributes' do
      expect(User.create!(balance: 100.0)).to be_valid
    end

    it 'generates an account number before creation' do
      expect(valid_user.account_number).to be_present
    end

    it 'requires a non-negative balance' do
      expect { create(:user, balance: -10) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'generates unique account numbers for each user' do
      users = create_list(:user, 10, balance: 100.0)
      account_numbers = users.map(&:account_number)
      expect(account_numbers.uniq.size).to eq(users.size)
    end
  end

  describe '#report_for' do
    let(:user) { create(:user, balance: 100.0) }
    before do
      book = Book.create!(title: 'Test Book', status: :borrowed)
      Transaction.create!(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
      Transaction.create!(user: user, book: book, transaction_type: :return, fee_amount: 10.0, created_at: Time.current)
    end

    it 'returns a monthly report' do
      report = user.report_for('monthly')
      expect(report[:period]).to eq('monthly')
      expect(report[:borrowed_books_count]).to eq(1)
      expect(report[:amount_spent]).to eq(10.0)
      expect(report[:start_date]).to be_a(Time)
      expect(report[:end_date]).to be_a(Time)
    end

    it 'returns an annual report' do
      report = user.report_for('annual')
      expect(report[:period]).to eq('annual')
      expect(report[:borrowed_books_count]).to eq(1)
      expect(report[:amount_spent]).to eq(10.0)
    end

    it 'raises an error for an invalid period' do
      expect { user.report_for('weekly') }.to raise_error(ArgumentError)
    end

    context 'when no transactions exist' do
      let(:user_no_tx) { create(:user, balance: 100.0) }
      it 'returns a report with zero borrowed_books_count and amount_spent' do
        report = user_no_tx.report_for('monthly')
        expect(report[:borrowed_books_count]).to eq(0)
        expect(report[:amount_spent]).to eq(0.0)
      end
    end

    context 'with boundary date conditions for monthly report' do
      let(:user) { create(:user, balance: 100.0) }
      let(:book) { create(:book, title: 'Boundary Book', status: :borrowed) }
      let(:beginning_of_month) { Time.current.beginning_of_month }
      let(:end_of_month) { Time.current.end_of_month }

      before do
        create(:transaction, user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: beginning_of_month)
        create(:transaction, user: user, book: book, transaction_type: :return, fee_amount: 10.0, created_at: end_of_month)
      end

      it 'includes transactions on the exact boundary times' do
        report = user.report_for('monthly')
        expect(report[:borrowed_books_count]).to eq(2)
        expect(report[:amount_spent]).to eq(20.0)
      end
    end

    context 'with boundary date conditions for annual report' do
      let(:user) { create(:user, balance: 100.0) }
      let(:book) { create(:book, title: 'Annual Boundary Book', status: :borrowed) }
      let(:beginning_of_year) { Time.current.beginning_of_year }
      let(:end_of_year) { Time.current.end_of_year }

      before do
        create(:transaction, user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: beginning_of_year)
        create(:transaction, user: user, book: book, transaction_type: :return, fee_amount: 20.0, created_at: end_of_year)
      end

      it 'includes transactions on the exact boundary times for annual report' do
        report = user.report_for('annual')
        expect(report[:borrowed_books_count]).to eq(2)
        expect(report[:amount_spent]).to eq(30.0)
      end
    end
  end
end
