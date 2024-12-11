class AddStockValueToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :stock_value, :decimal
  end
end
