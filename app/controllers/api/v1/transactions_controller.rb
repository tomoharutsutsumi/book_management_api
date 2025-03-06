# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/transactions_controller.rb
    #
    # Controller for handling API transactions related to book borrow and return operations.
    class TransactionsController < ApplicationController
      def borrow_book
        user = User.find(params[:user_id])
        book = Book.find(params[:book_id])

        error = borrow_conditions_errors(user, book)

        return render json: { error: error }, status: :unprocessable_entity if error.present?

        begin
          Transaction.process_borrow!(user, book)
          render json: { message: 'Book borrowed successfully', user_id: user.id, book_id: book.id }, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.message }, status: :unprocessable_entity
        end
      end

      def return_book
        user = User.find(params[:user_id])
        book = Book.find(params[:book_id])

        error = return_conditions_error(book)

        return render json: { error: error }, status: :unprocessable_entity if error.present?

        begin
          Transaction.process_return!(user, book)
          render json: { message: 'Book returned successfully', user_id: user.id, book_id: book.id }, status: :ok
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def sufficient_balance?(user)
        user.balance >= Transaction::DEFAULT_BORROW_FEE
      end

      def borrow_conditions_errors(user, book)
        return 'User not found' unless user
        return 'Book not found' unless book
        return 'Book is not available for borrowing' unless book.available?
        return 'Insufficient balance to borrow the book' unless sufficient_balance?(user)

        nil
      end

      def return_conditions_error(book)
        return 'Book is not currently borrowed' unless book.borrowed?

        nil
      end
    end
  end
end
