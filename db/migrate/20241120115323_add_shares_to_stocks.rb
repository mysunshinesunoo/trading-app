class AddSharesToStocks < ActiveRecord::Migration[7.2]
  def change
    add_column :stocks, :shares, :integer
  end
end
