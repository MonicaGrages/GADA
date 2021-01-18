class AddBodyToBlogs < ActiveRecord::Migration[6.0]
  def change
    add_column :blogs, :body, :string
  end
end
