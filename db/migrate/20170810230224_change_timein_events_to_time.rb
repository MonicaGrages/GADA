class ChangeTimeinEventsToTime < ActiveRecord::Migration[5.1]
  def up
    remove_column :events, :time
    add_column :events, :time, :time
  end

  def down
    remove_column :events, :time
    add_column :events, :time, :string
  end
end
