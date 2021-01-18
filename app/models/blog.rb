class Blog < ApplicationRecord
  has_rich_text :body

  validates :title, presence: true
  validates :author, presence: true
  validates :content, presence: true
end
