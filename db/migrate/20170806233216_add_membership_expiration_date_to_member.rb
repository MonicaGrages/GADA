class AddMembershipExpirationDateToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :membership_expiration_date, :date
  end
end
