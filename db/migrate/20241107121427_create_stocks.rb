class CreateStocks < ActiveRecord::Migration[7.2]
  def change
    create_table :stocks do |t|
      t.string :stock_name
      t.integer :quantity
      t.integer :price_per_stock
      t.integer :total_price

      t.timestamps
    end
  end
end
