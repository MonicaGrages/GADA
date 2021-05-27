class AddDefaultsToMembershipPricingFields < ActiveRecord::Migration[6.0]
  def change
    change_column :settings, :rd_membership_price, :integer, null: false, default: 35
    change_column :settings, :student_membership_price, :integer, null: false, default: 10
    change_column :settings, :minimum_sliding_scale_rd_membership_price, :integer, null: false, default: 20
  end
end
