class AddNewMembershipPricesToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :dtr_membership_price, :integer, default: 25, null: false
    add_column :settings, :retired_membership_price, :integer, default: 35, null: false
    add_column :settings, :subscriber_membership_price, :integer, default: 40, null: false
    add_column :settings, :offer_student_sponsorship, :bool, default: false, null: false
  end
end
