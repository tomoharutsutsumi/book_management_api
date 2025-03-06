# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/users_controller.rb
    #
    # Controller for handling API requests related to Users.
    class UsersController < ApplicationController
      def create
        @user = User.new(user_params)

        if @user.save
          render json: { id: @user.id }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        user = User.find(params[:id])

        borrowed_books = Book.borrowed_by(user)

        render json: {
          id: user.id,
          current_balance: user.balance.to_f,
          borrowed_book: borrowed_books.as_json(only: %i[id title])
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def reports
        user = User.find(params[:id])
        period = params[:period]

        begin
          report = user.report_for(period)
          render json: report, status: :ok
        rescue ArgumentError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      private

      def user_params
        params.require(:user).permit(:id, :balance)
      end
    end
  end
end
