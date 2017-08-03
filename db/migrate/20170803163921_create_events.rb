class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.date :date
      t.string :link
      t.string :link_text

      t.timestamps
    end
  end
end
