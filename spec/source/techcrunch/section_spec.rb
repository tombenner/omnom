require 'spec_helper'

describe Omnom::Source::Techcrunch::Section do
  include Omnom::SourceHelpers

  class DummyTechcrunchSectionFeed < Omnom::Feed
    sources do
      techcrunch__section section: :startups
    end
  end

  before(:all) do
    set_posts_for_source_key(DummyTechcrunchSectionFeed, :techcrunch__section)
  end

  it 'creates enough posts' do
    @posts.count.should be >= 20
  end
end
