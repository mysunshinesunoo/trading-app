class AddSymbolToStocks < ActiveRecord::Migration[7.2]
  def change
    add_column :stocks, :symbol, :string
  end
end
