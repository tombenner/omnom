module Omnom
  module Source
    module Twitter
      class Search < Source::Base
        icon 'https://twitter.com/favicon.ico'
        every '5m'
        required_config :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret
        required_options :term

        def self.configure
          if Omnom.config.twitter.present? && Omnom.config.twitter.base.present?
            ::Twitter.configure do |configure|
              configure.consumer_key = Omnom.config.twitter.base.consumer_key
              configure.consumer_secret = Omnom.config.twitter.base.consumer_secret
              configure.oauth_token = Omnom.config.twitter.base.oauth_token
              configure.oauth_token_secret = Omnom.config.twitter.base.oauth_token_secret
            end
          end
        end

        def get_raw_posts
          search_options = {
            count: 100,
            result_type: 'recent'
          }
          search_options.reverse_merge!(@options[:search_options]) if @options[:search_options]
          ::Twitter.search(@options[:term], search_options).results
        end

        def post_attributes(tweet)
          username = tweet.from_user

          media = nil
          if tweet.media.present?
            media = {}
            tweet.media.each do |medium|
              type = medium.class.name.demodulize
              media[type] ||= []
              media[type] << medium.attrs
            end
          end

          geo = nil
          if tweet.geo
            geo = {
              lat: tweet.geo.lat,
              lng: tweet.geo.lng
            }
          end

          if tweet.source =~ /<a[^>]*>(.*?)<\/a>/
            source = $1
          else
            source = tweet.source
          end

          {
            title: "@#{username}: #{tweet.text}",
            guid: tweet.id.to_s,
            url: "https://twitter.com/#{username}/status/#{tweet.id}",
            published_at: tweet.created_at,
            author_name: username,
            author_url: "https://twitter.com/#{username}",
            other: {
              geo: geo,
              media: media,
              source: source,
              to_user: tweet.to_user
            }
          }
        end
      end
    end
  end
end
