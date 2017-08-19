class CreateBoardMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :board_members do |t|
      t.string :name
      t.string :position
      t.string :description
      t.string :photo

      t.timestamps
    end
  end
end
