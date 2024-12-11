class Admin::TransactionsController < ApplicationController
  before_action :authenticate_user!
  def index
    @transactions = Transaction.all
    @user = User.all
  end

  def show
    @transaction = Transaction.find(params[:id])
    @user = User.find(@transaction.user_id)
  end


  private

  def transaction_params
    params.require(:transaction).permit(:transaction_type, :stock_name, :quantity, :price_per_stock, :total_price)
  end


end