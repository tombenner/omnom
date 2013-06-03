require 'spec_helper'

describe Omnom::Source::Facebook::Default do
  include Omnom::SourceHelpers

  class DummyFacebookFeed < Omnom::Feed
    sources do
      facebook
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyFacebookFeed, :facebook)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 10
  end
end