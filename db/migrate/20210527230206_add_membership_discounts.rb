class AddMembershipDiscounts < ActiveRecord::Migration[6.0]
  def change
    create_table :membership_discounts do |t|
      t.integer :discount_amount_in_dollars, null: false, default: 0
      t.string :membership_type, null: false, default: "RD"
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false

      t.timestamps
    end
  end
end
