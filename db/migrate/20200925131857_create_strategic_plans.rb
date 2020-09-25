class CreateStrategicPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :strategic_plans do |t|
      t.text :content
      t.timestamps
    end
  end
end
