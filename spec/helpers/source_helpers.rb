module Omnom
  module SourceHelpers
    def set_posts_for_source_key(feed_class, source_key)
      @feed = feed_class.new
      @feed.update_by_source_key(source_key)
      @posts = PostsOrigin.where(feed_key: @feed.key, source_key: source_key).includes(:post).map(&:post)
    end
  end
end