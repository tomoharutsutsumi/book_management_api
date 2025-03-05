class Api::V1::UsersController < ApplicationController
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

    # Using includes for transactions to enable eager loading.
    # Although currently the filtering is the same with or without includes,
    # this may be beneficial for future transaction-related optimizations.
    borrowed_books = Book
      .includes(:transactions)
      .where(
        transactions: { user_id: user.id, transaction_type: Transaction.transaction_types[:borrow] }
      )
      .where(status: Book.statuses[:borrowed])

    render json: {
      id: user.id,
      account_number: user.account_number,
      balance: user.balance,
      borrowed_book: borrowed_books.as_json(only: [:id, :title])
    }
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
    render json: { error: "User not found" }, status: :not_found
  end

  private

  def user_params
    params.require(:user).permit(:id)
  end
end
