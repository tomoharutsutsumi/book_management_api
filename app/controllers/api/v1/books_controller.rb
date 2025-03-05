class Api::V1::BooksController < ApplicationController
  def income
    book = Book.find(params[:id])
    total_income = book.income(start_date: params[:start_date], end_date: params[:end_date])
    render json: { book_id: book.id, total_income: total_income }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Book not found" }, status: :not_found
  end
end
