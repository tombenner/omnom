require 'spec_helper'

describe Omnom::Source::GoogleAnalytics::Visitors do
  include Omnom::SourceHelpers

  if Omnom.config.google_analytics.base.profile_id
    class DummyGoogleAnalyticsVisitorsFeed < Omnom::Feed
      sources do
        google_analytics__visitors profile_id: Omnom.config.google_analytics.base.profile_id
      end
    end

    before(:all) do
      set_posts_for_source_key(DummyGoogleAnalyticsVisitorsFeed, :google_analytics__visitors)
    end

    it 'creates enough posts' do
      @posts.count.should be >= 1
    end
  end
end