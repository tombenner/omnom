module Omnom
  module PostsHelper
    def post_timeago(post)
      content_tag :abbr, post.published_at.utc, title: post.published_at.iso8601, class: 'timeago'
    end

    def post_source_icon(post)
      return nil if post.source.blank? || post.source.settings[:icon].blank?
      content_tag :div, image_tag(post.source.settings[:icon]), class: 'post-source-icon'
    end
  end
end