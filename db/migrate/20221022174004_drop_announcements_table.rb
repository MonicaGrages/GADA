class DropAnnouncementsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :announcements
  end
end
