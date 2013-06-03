require 'spec_helper'

describe Omnom::Source::Reddit::Default do
  include Omnom::SourceHelpers

  class DummyRedditFeed < Omnom::Feed
    sources do
      reddit
    end
  end

  class DummyRedditSubredditFeed < Omnom::Feed
    sources do
      reddit subreddit: 'r/programming'
    end
  end

  it 'creates enough posts' do
    set_posts_for_source_key(DummyRedditFeed, :reddit)
    @posts.count.should be >= 25
  end

  it 'creates posts with enough comments' do
    set_posts_for_source_key(DummyRedditFeed, :reddit)
    comments_counts = @posts.collect { |post| post.comments_count }
    comments_counts.select { |count| count > 100 }.length.should be >= 5
  end

  it 'creates posts with enough likes' do
    set_posts_for_source_key(DummyRedditFeed, :reddit)
    likes_counts = @posts.collect { |post| post.other.present? ? post.other[:likes_count].to_i : nil }
    likes_counts.select { |count| count && count > 500 }.length.should be >= 20
  end

  it 'creates enough posts for subreddits' do
    set_posts_for_source_key(DummyRedditSubredditFeed, :reddit)
    @posts.count.should be >= 25
  end

  it 'creates the correct posts for subreddits' do
    set_posts_for_source_key(DummyRedditSubredditFeed, :reddit)
    @posts.first.comments_url.should start_with 'http://www.reddit.com/r/programming'
  end
end