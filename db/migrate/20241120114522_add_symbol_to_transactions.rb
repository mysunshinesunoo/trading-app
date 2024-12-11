class AddSymbolToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :symbol, :string
  end
end
