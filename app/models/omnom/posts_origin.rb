module Omnom
  class PostsOrigin < ActiveRecord::Base
    attr_accessible :post_id, :feed_key, :source_key, :source_id

    belongs_to :post

    validates_presence_of :post_id, :feed_key, :source_key, :source_id

    def feed
      Omnom.feeds[feed_key]
    end

    def source
      return nil unless feed
      feed.source_by_source_id(source_id)
    end
  end
end
