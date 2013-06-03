require 'spec_helper'

describe Omnom::Source::Feed do
  include Omnom::SourceHelpers

  class DummyFeedFeed < Omnom::Feed
    sources do
      feed url: 'http://feeds.bbci.co.uk/news/rss.xml'
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyFeedFeed, :feed)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end