require 'spec_helper'

describe Omnom::Source::HackerNews::Default do
  include Omnom::SourceHelpers

  class DummyHackerNewsFeed < Omnom::Feed
    sources do
      hacker_news
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyHackerNewsFeed, :hacker_news)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 25
  end

  it 'creates posts with enough comments' do
    comments_counts = @posts.collect { |post| post.comments_count }
    comments_counts.select { |count| count > 5 }.length.should be >= 8
  end

  it 'creates posts with enough points' do
    points_counts = @posts.collect { |post| post.other[:points_count] }
    points_counts.select { |count| count > 10 }.length.should be >= 10
  end
end