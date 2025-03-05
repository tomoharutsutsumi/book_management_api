class Api::V1::TransactionsController < ApplicationController
  def borrow_book
    user = User.find(params[:user_id])
    book = Book.find(params[:book_id])

    if book.available?
      if user.balance < Transaction::DEFAULT_BORROW_FEE
        render json: { error: "Insufficient balance to borrow the book" }, status: :unprocessable_entity and return
      end

      begin
        Transaction.process_borrow!(user, book)
        render json: { message: "Book borrowed successfully", user_id: user.id, book_id: book.id }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "Book is not available for borrowing" }, status: :unprocessable_entity
    end
  end


  def return_book
    user = User.find(params[:user_id])
    book = Book.find(params[:book_id])

    if book.borrowed?
      begin
        Transaction.process_return!(user, book)
        render json: { message: "Book returned successfully, fee deducted", user_id: user.id, book_id: book.id }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "Book is not currently borrowed" }, status: :unprocessable_entity
    end
  end
end
