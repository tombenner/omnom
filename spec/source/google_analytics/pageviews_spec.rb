require 'spec_helper'

describe Omnom::Source::GoogleAnalytics::Pageviews do
  include Omnom::SourceHelpers

  if Omnom.config.google_analytics.base.profile_id
    class DummyGoogleAnalyticsPageviewsFeed < Omnom::Feed
      sources do
        google_analytics__pageviews profile_id: Omnom.config.google_analytics.base.profile_id
      end
    end

    before(:all) do
      set_posts_for_source_key(DummyGoogleAnalyticsPageviewsFeed, :google_analytics__pageviews)
    end

    it 'creates enough posts' do
      @posts.count.should be >= 1
    end
  end
end