class RenameTypeToMembershipType < ActiveRecord::Migration[5.1]
  def change
    rename_column :members, :type, :membership_type
  end
end
