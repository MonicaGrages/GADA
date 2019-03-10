class CreateCheckins < ActiveRecord::Migration[5.1]
  def change
    create_table :checkins do |t|
      t.timestamps
    end

    add_reference :checkins, :events, foreign_key: true
    add_reference :checkins, :members, foreign_key: true
  end
end
