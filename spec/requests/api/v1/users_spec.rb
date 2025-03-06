# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'POST /api/v1/users' do
    it 'creates a new user' do
      post '/api/v1/users', params: { user: { balance: 100.0 } }, as: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
    end
  end

  describe 'GET /api/v1/users/:id' do
    let!(:user) { create(:user, balance: 50.0) }
    it 'shows the user account details' do
      get "/api/v1/users/#{user.id}", as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['account_number']).to eq(user.account_number)
    end
  end

  describe 'GET /api/v1/users/:id/reports' do
    let!(:user) { create(:user, balance: 50.0) }
    before do
      book = Book.create!(title: 'Test Book', status: :borrowed)
      Transaction.create!(user: user, book: book, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
      Transaction.create!(user: user, book: book, transaction_type: :return, fee_amount: 10.0, created_at: Time.current)
    end

    it 'returns a monthly report' do
      get "/api/v1/users/#{user.id}/reports?period=monthly", as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['borrowed_books_count']).to eq(1)
      expect(json['amount_spent']).to eq(10.0)
    end

    it 'returns an error for invalid period' do
      get "/api/v1/users/#{user.id}/reports?period=weekly", as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
