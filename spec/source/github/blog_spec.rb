require 'spec_helper'

describe Omnom::Source::Github::Blog do
  include Omnom::SourceHelpers

  class DummyGithubBlogFeed < Omnom::Feed
    sources do
      github__blog
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyGithubBlogFeed, :github__blog)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end