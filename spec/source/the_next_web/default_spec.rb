require 'spec_helper'

describe Omnom::Source::TheNextWeb::Default do
  include Omnom::SourceHelpers

  class DummyTheNextWebFeed < Omnom::Feed
    sources do
      the_next_web
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyTheNextWebFeed, :the_next_web)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end