require 'spec_helper'

describe Omnom::Source::Instagram::Default do
  include Omnom::SourceHelpers

  class DummyInstagramFeed < Omnom::Feed
    sources do
      instagram
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyInstagramFeed, :instagram)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end