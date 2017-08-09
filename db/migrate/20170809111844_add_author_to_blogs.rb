class AddAuthorToBlogs < ActiveRecord::Migration[5.1]
  def change
    add_column :blogs, :author, :string
  end
end
