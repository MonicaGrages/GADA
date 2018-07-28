class AddEmailToBoardMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :board_members, :email, :string
  end
end
