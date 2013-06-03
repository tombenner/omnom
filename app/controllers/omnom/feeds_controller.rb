module Omnom
  class FeedsController < Omnom::ApplicationController
    def index
      feeds = Omnom.feeds
      @feed_key = feeds.keys.first
      show
      render template: 'omnom/feeds/show'
    end

    def show
      @feed_key ||= params[:id]
      @feed = Omnom.feeds[@feed_key]
      render_404 and return if @feed.blank?
      per_page = 20
      page = params[:page] || 1
      offset = (page.to_i - 1) * per_page
      @posts = @feed.posts.order('is_read ASC, published_at DESC').limit(20).offset(offset)
      render(:partial => "omnom/posts/#{@feed.template}/post", :collection => @posts) if request.xhr?
    end
  end
end
