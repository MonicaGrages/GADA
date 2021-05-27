class AddSlidingScaleToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :offer_sliding_scale_membership_pricing, :boolean, null: false, default: false
    add_column :settings, :minimum_sliding_scale_rd_membership_price, :integer
  end
end
