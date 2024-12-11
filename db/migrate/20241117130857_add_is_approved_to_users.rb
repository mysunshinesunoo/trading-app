class AddIsApprovedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_approved, :boolean, default: false, null: false
  end
end
