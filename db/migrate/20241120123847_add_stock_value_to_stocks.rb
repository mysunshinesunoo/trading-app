class AddStockValueToStocks < ActiveRecord::Migration[7.2]
  def change
    add_column :stocks, :stock_value, :decimal
  end
end
