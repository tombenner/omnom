require 'spec_helper'

describe Omnom::Source::GoogleAnalytics::Default do
  include Omnom::SourceHelpers

  if Omnom.config.google_analytics.base.profile_id
    class DummyGoogleAnalyticsDefaultFeed < Omnom::Feed
      sources do
        google_analytics profile_id: Omnom.config.google_analytics.base.profile_id, metrics: [:pageviews]
      end
    end

    before(:all) do
      set_posts_for_source_key(DummyGoogleAnalyticsDefaultFeed, :google_analytics)
    end

    it 'creates enough posts' do
      @posts.count.should be >= 1
    end
  end
end