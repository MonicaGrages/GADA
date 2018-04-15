class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.boolean :offer_discounted_membership

      t.timestamps
    end
  end
end
