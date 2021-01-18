class BlogBodyMigrator
  include ActionView::Helpers::TextHelper

  def migrate_content_to_action_text_body!
    Blog.all.each do |blog|
      blog.update_attributes(body: simple_format(blog.content).gsub(/\n\n/, "<br>"))
    end
  end
end
