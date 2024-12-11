class AddHoldingsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :holdings, :integer
  end
end
