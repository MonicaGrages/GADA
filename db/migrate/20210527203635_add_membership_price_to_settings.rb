class AddMembershipPriceToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :rd_membership_price, :integer
    add_column :settings, :student_membership_price, :integer
  end
end
