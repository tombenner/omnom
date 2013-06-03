require 'spec_helper'

describe Omnom::Source::Github::Default do
  include Omnom::SourceHelpers

  class DummyGithubFeed < Omnom::Feed
    sources do
      github
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyGithubFeed, :github)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end