module Omnom
  module Source
    module GoogleAnalytics
      class Default < Source::Base
        icon 'https://www.google.com/images/icons/product/analytics-32.png'
        every '1h'
        required_config :_client_id, :_client_secret, :_oauth_token, :_oauth_refresh_token
        required_options :profile_id, :metrics

        def after_initialize
          set_options
          initialize_legato
        end

        def set_options
          defaults = {
            metrics: nil,
            dimensions: nil,
            filters: {
              start_date: Proc.new { Date.yesterday },
              end_date: Proc.new { Date.yesterday }
            },
            attribute_methods: {}
          }
          @options.reverse_merge!(defaults)
        end

        def initialize_legato
          @legato_model_name = "LegatoModel#{@source_id}"
          @legato_model = create_legato_model
          @legato_user = ::Legato::User.new(get_access_token)
          raise "Unable to create Legato user in #{self.class}" and return if @legato_user.blank?
          @legato_profile = @legato_user.profiles.select do |profile|
            profile.attributes['internalWebPropertyId'] == @options[:profile_id].to_s
          end.first
          raise "Profile with ID '#{@options[:profile_id]}' not found in #{self.class}" and return if @legato_profile.blank?
        end

        def get_raw_posts
          @legato_filters = @options[:filters]
          @legato_filters.each do |key, value|
            @legato_filters[key] = value.is_a?(Proc) ? value.call : value
          end
          query = @legato_model.results(@legato_profile, @legato_filters)
          query.collect do |result|
            {
              query: query,
              profile: query.profile,
              result: result
            }
          end
        end

        def post_attributes(response)
          {
            title: attribute_value(:title, response),
            guid: attribute_value(:guid, response),
            url: attribute_value(:url, response),
            published_at: attribute_value(:published_at, response),
            author_name: attribute_value(:author_name, response),
            author_url: attribute_value(:author_url, response),
            other: attribute_value(:other, response)
          }
        end

        def attribute_value(attribute, response)
          return @options[:attribute_methods][attribute].call(response) if @options[:attribute_methods][attribute].present?
          send(attribute, response)
        end

        def title(response)
          date = @legato_filters[:end_date].strftime('%a, %_m/%e').squeeze
          "#{response[:result].send(metric)} #{metric} on #{@legato_profile.name} (#{date})"
        end

        def guid(response)
          "#{@legato_profile.name}:#{metric}:#{published_at(response)}"
        end

        def url(response)
          'https://www.google.com/analytics/'
        end

        def published_at(response)
          return nil if @legato_filters[:end_date].blank?
          Time.parse(@legato_filters[:end_date].to_s)
        end

        def author_name(response)
          @legato_profile.name
        end

        def author_url(response)
          "http://#{@legato_profile.name}"
        end

        def other(response)
          response[:result].marshal_dump
        end

        def metric
          @options[:metrics].first
        end

        protected

        def create_legato_model
          metrics_value = @options[:metrics]
          dimensions_value = @options[:dimensions]
          klass = Class.new do
            extend Legato::Model
            metrics *metrics_value
            dimensions *dimensions_value
          end
          Object.const_set(@legato_model_name, klass)
        end

        def get_access_token
          base_config = Omnom.config.google_analytics.base
          refresh_client = OAuth2::Client.new(base_config.client_id, base_config.client_secret, {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth', :token_url => '/o/oauth2/token'})
          access_token = OAuth2::AccessToken.new(refresh_client, base_config.oauth_token, {refresh_token: base_config.oauth_refresh_token})
          access_token = access_token.refresh!
          access_token
        end
      end
    end
  end
end
