require 'rails_helper'

RSpec.describe "Api::V1::Transactions", type: :request do
  let!(:user) { create(:user, balance: 100.0) }
  let!(:book) { create(:book, title: "Test Book", status: :available) }

  describe "POST /api/v1/transactions/borrow" do
    it "allows a user to borrow a book if available and has sufficient balance" do
      post "/api/v1/transactions/borrow", params: { user_id: user.id, book_id: book.id }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Book borrowed successfully")
      book.reload
      expect(book.borrowed?).to be true
    end

    it "returns an error if the book is not available" do
      book.update!(status: :borrowed)
      post "/api/v1/transactions/borrow", params: { user_id: user.id, book_id: book.id }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Book is not available for borrowing")
    end

    it "returns an error if user has insufficient balance" do
      user.update!(balance: 5.0)
      post "/api/v1/transactions/borrow", params: { user_id: user.id, book_id: book.id }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Insufficient balance to borrow the book")
    end
  end

  describe "POST /api/v1/transactions/return" do
    let!(:book_borrowed) { Book.create!(title: "Borrowed Book", status: :borrowed) }
    before do
      Transaction.create!(user: user, book: book_borrowed, transaction_type: :borrow, fee_amount: 0.0, created_at: Time.current)
    end

    it "allows a user to return a borrowed book" do
      original_balance = user.balance
      post "/api/v1/transactions/return", params: { user_id: user.id, book_id: book_borrowed.id }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Book returned successfully, fee deducted")
      user.reload
      book_borrowed.reload
      expect(user.balance).to eq(original_balance - Transaction::DEFAULT_BORROW_FEE)
      expect(book_borrowed.available?).to be true
    end

    it "returns an error if the book is not currently borrowed" do
      book_borrowed.update!(status: :available)
      post "/api/v1/transactions/return", params: { user_id: user.id, book_id: book_borrowed.id }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Book is not currently borrowed")
    end
  end
end
