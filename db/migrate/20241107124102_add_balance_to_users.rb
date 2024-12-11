class AddBalanceToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :balance, :decimal, default: 0.0, precision: 10, scale: 2
  end
end
