require 'spec_helper'

describe Omnom::Source::Xkcd::Default do
  include Omnom::SourceHelpers

  class DummyXkcdFeed < Omnom::Feed
    sources do
      xkcd
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyXkcdFeed, :xkcd)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 3
  end

  it 'creates posts with images' do
    image_urls = @posts.collect { |p| p.other[:images].first[:image_url] }.compact
    image_urls.length.should == @posts.length
  end
end