require 'spec_helper'

describe Omnom::Source::Slashdot::Default do
  include Omnom::SourceHelpers

  class DummySlashdotFeed < Omnom::Feed
    sources do
      slashdot
    end
  end

  before(:all) do
    set_posts_for_source_key(DummySlashdotFeed, :slashdot)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end

  it 'creates posts with enough comments' do
    comments_counts = @posts.collect { |post| post.comments_count }
    comments_counts.select { |count| count && count > 5 }.length.should be >= 8
  end
end