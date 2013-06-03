require 'spec_helper'

describe Omnom::Source::Twitter::Search do
  include Omnom::SourceHelpers

  class DummyTwitterSearchFeed < Omnom::Feed
    sources do
      twitter__search term: 'cats'
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyTwitterSearchFeed, :twitter__search)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 100
  end
end