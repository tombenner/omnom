require 'spec_helper'

describe Omnom::Source::Techcrunch::Default do
  include Omnom::SourceHelpers

  class DummyTechcrunchFeed < Omnom::Feed
    sources do
      techcrunch
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyTechcrunchFeed, :techcrunch)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 20
  end
end