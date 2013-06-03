require 'spec_helper'

describe Omnom::Source::Reddit::Images do
  include Omnom::SourceHelpers

  class DummyRedditImagesFeed < Omnom::Feed
    sources do
      reddit__images subreddit: 'r/pics'
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyRedditImagesFeed, :reddit__images)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 20
  end

  it 'creates posts with enough comments' do
    comments_counts = @posts.collect { |post| post.comments_count }
    comments_counts.select { |count| count > 20 }.length.should be >= 5
  end

  it 'creates an image for each post' do
    image_urls = @posts.collect { |post| post.other[:images].first[:image_url] }.compact
    image_urls.length.should equal @posts.length
  end
end