require 'spec_helper'

describe Omnom::Source::Github::BlogSection do
  include Omnom::SourceHelpers

  class DummyGithubBlogSectionFeed < Omnom::Feed
    sources do
      github__blog_section section: :meetups
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyGithubBlogSectionFeed, :github__blog_section)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end
