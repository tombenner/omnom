require 'omnom/source/google_analytics/default'

module Omnom
  module Source
    module GoogleAnalytics
      class Visitors < Default
        icon 'https://www.google.com/images/icons/product/analytics-32.png'
        every '1h'
        required_config :_client_id, :_client_secret, :_oauth_token, :_oauth_refresh_token
        required_options :profile_id

        def set_options
          super
          @options[:metrics] = [:visitors]
        end
      end
    end
  end
end
