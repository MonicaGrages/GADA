class CreateCheckins < ActiveRecord::Migration[5.1]
  def change
    create_table :checkins do |t|
      t.timestamps
    end

    add_reference :checkins, :event, foreign_key: true
    add_reference :checkins, :member, foreign_key: true
  end
end
