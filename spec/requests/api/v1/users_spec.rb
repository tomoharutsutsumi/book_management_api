# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'POST /api/v1/users' do
    it 'creates a new user' do
      post '/api/v1/users', params: { user: { balance: 100.0 } }, as: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
      created_user = User.find(json['id'])
      expect(created_user.balance).to eq(100.0)
    end
  end

  describe 'GET /api/v1/users/:id' do
    let!(:user) { create(:user, balance: 50.0) }
    let!(:book) { create(:book, title: 'Test Book', status: :available) }
    before do
      Transaction.process_borrow!(user, book)
    end
    it 'shows the user account details' do
      get "/api/v1/users/#{user.id}", as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['current_balance']).to eq(50.0)
      expect(json['borrowed_book']).to eq([{"id"=>1, "title"=>"Test Book"}])
    end

     context 'when user returns book' do
      it 'updates the user account details' do
        Transaction.process_return!(user, book)
        get "/api/v1/users/#{user.id}", as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(user.id)
        expect(json['current_balance']).to eq(40.0)
        expect(json['borrowed_book']).to eq([])
      end
    end

    context 'when user does not exist' do
      it 'returns a 404 not found error' do
        get "/api/v1/users/99999", as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/users/:id/reports' do
    let!(:user) { create(:user, balance: 50.0) }
    let!(:book) { create(:book, title: 'Test Book', status: :borrowed) }
    context 'when transactions exist in the current month' do
      before do
        Transaction.process_borrow!(user, book)
        Transaction.process_return!(user, book)
      end

      it 'returns a monthly report' do
        report = user.report_for('monthly')
        expect(report[:period]).to eq('monthly')
        expect(report[:borrowed_books_count]).to eq(1)
        expect(report[:amount_spent]).to eq(10.0)
        expect(report[:start_date]).to be_a(Time)
        expect(report[:end_date]).to be_a(Time)
      end
    end

    context 'when transactions span across multiple months within the same year' do
      before do
        Transaction.create!(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
        Transaction.create!(user: user, book: book, transaction_type: :return, fee_amount: 10.0, created_at: Time.current)

        last_month = Time.current.last_month
        Transaction.create!(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: last_month)
        Transaction.create!(user: user, book: book, transaction_type: :return, fee_amount: 15.0, created_at: last_month)
      end

      it 'returns an annual report including transactions from previous months' do
        report = user.report_for('annual')
        expect(report[:period]).to eq('annual')
        expect(report[:borrowed_books_count]).to eq(2)
        expect(report[:amount_spent]).to eq(25.0)
      end
    end

    it 'returns an error for invalid period' do
      get "/api/v1/users/#{user.id}/reports?period=weekly", as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context 'when user does not exist' do
      it 'returns a 404 not found error' do
        get "/api/v1/users/99999/reports?period=monthly", as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when no transactions exist for the user' do
      let!(:user_no_tx) { create(:user, balance: 100.0) }

      it 'returns a report with zero values' do
        get "/api/v1/users/#{user_no_tx.id}/reports?period=monthly", as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['borrowed_books_count']).to eq(0)
        expect(json['amount_spent']).to eq(0.0)
      end
    end
  end
end
