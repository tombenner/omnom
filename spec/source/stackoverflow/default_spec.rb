require 'spec_helper'

describe Omnom::Source::Stackoverflow::Default do
  include Omnom::SourceHelpers

  class DummyStackoverflowFeed < Omnom::Feed
    sources do
      stackoverflow path: 'questions/tagged/ruby-on-rails'
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyStackoverflowFeed, :stackoverflow)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 15
  end
end