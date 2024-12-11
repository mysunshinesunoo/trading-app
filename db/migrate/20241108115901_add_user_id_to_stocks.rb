class AddUserIdToStocks < ActiveRecord::Migration[7.2]
  def change
    add_reference :stocks, :user, null: false, foreign_key: true
  end
end
