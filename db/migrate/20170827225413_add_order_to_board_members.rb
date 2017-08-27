class AddOrderToBoardMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :board_members, :order, :integer
  end
end
