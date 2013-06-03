module Omnom
  module Source
    class Base
      class << self
        attr_writer :settings

        def inherited(child)
          Omnom::FeedSourcesDSL.create_source_method(child)
          Omnom.add_source(child)

          # Inherit settings of the superclass if it isn't a base source class (e.g. Base, Atom)
          superclass_is_a_base_source_class = child.superclass.name.split('::').length <= 3
          if !superclass_is_a_base_source_class && child.superclass.respond_to?(:settings)
            child.settings = child.superclass.settings.dup
          end
        end

        # Implement configuration code in child class if necessary (e.g. code that would be in an initializer)
        def configure
        end

        def settings
          @settings ||= {
            key: key,
            guid_namespace: key
          }
        end

        def config
          config_keys = full_key.split('__')
          config_keys.inject(Omnom.config) { |config, key| config = config[key] unless config.nil? }
        end

        def full_key
          name.sub('Omnom::Source::', '').underscore.gsub('/', '__')
        end

        def key
          full_key.sub(/__default$/, '')
        end

        def cron(cron)
          settings[:cron] = cron
        end

        def every(every)
          settings[:every] = every
        end

        def feed_url(url)
          settings[:feed_url] = url
          settings[:icon] = icon_from_url(url) unless settings[:icon].present?
        end

        def guid_namespace(guid_namespace)
          settings[:guid_namespace] = guid_namespace
        end

        def icon(url)
          settings[:icon] = url
        end

        def required_config(*keys)
          settings[:required_config] = keys
        end

        def required_options(*keys)
          settings[:required_options] = keys
        end

        def url(url)
          settings[:url] = url
          settings[:icon] = icon_from_url(url) unless settings[:icon].present?
        end

        def icon_from_url(url)
          return if url.blank?
          uri = URI(url)
          "http://#{uri.host}/favicon.ico"
        end
      end
      
      include ParserMethods

      attr_accessor :feed_key
      attr_reader :config, :options, :settings, :source_id, :key

      def initialize(settings={}, options={})
        settings ||= {}
        options ||= {}
        @settings = self.class.settings.dup.merge(settings)
        @options = options
        @url = @settings[:url]
        @key = self.class.key
        @source_id = Digest::SHA1.hexdigest("#{@key}-#{hash_to_consistent_string(@options)}")
        @config = self.class.config
        validate_config
        after_initialize
      end

      def after_initialize
      end

      def update
        return unless Omnom.is_database_ready?
        set_agent
        authenticate
        set_page
        update_posts
        filter_past_posts
        @page = nil
        @agent = nil
      end

      protected

      def validate_config
        if @settings[:required_config]
          namespace_key, class_key = self.class.full_key.split('__', 2)
          config_base = Omnom.config[namespace_key]
          @settings[:required_config].each do |config_key|
            config_key = config_key.to_s
            if config_key.start_with?('_')
              parent_key = 'base'
              child_key = config_key[1..-1]
            else
              parent_key = class_key
              child_key = config_key
            end
            value = config_base[parent_key]
            value = value[child_key] if value && child_key
            Reporting.warn_once "Omnom.config.#{namespace_key}.#{parent_key}.#{child_key}", "#{namespace_key} requires a config value for the key \"#{namespace_key}.#{parent_key}.#{child_key}\". Please set it in omnom.local.yml." unless value.present?
          end
        end
      end

      def validate_options
        if @settings[:required_options]
          @settings[:required_options].each do |options_key|
            Reporting.warn_once "Omnom.options.#{key}.#{options_key}", "#{key} requires an options value for the key \"#{options_key}\". Please set it in the feed definition." if !@options.key?(options_key)
          end
        end
      end

      # Implement authentication in child class if necessary
      def authenticate
      end

      # Implement in child class unless a feed is being used
      def get_raw_posts
        if @settings[:feed_url].present?
          return Feedzirra::Feed.fetch_and_parse(@settings[:feed_url]).entries
        end
        nil
      end

      def set_page
        begin
          @page = @agent.get(@url) if @url.present?
        rescue Net::HTTP::Persistent::Error, Net::HTTPBadGateway => e
          warn "Exception in #{self.class} for URL #{@url}: #{e.class}: #{e.message}"
        end
      end

      def set_agent
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Firefox'
        @agent.max_history = 10
        # Mechanize reads Atom feeds as a Mechanize::File, but we want a parsable Mechanize::Page
        @agent.post_connect_hooks << lambda do | _, _, response, _ |
          if response.content_type.blank? || response.content_type == 'application/atom+xml'
            response.content_type = 'text/html'
          end
        end
      end

      def update_posts
        raise "No feed_key set in #{self}" if @feed_key.blank?
        raw_posts = get_raw_posts
        return if raw_posts.blank?
        raw_posts = prepare_raw_posts(raw_posts)
        raw_posts.each do |raw_post|
          attributes = post_attributes(raw_post)
          next if attributes.blank?
          attributes[:guid_namespace] = @settings[:guid_namespace]
          attributes[:published_at] = attributes[:published_at].utc if attributes[:published_at].respond_to?(:utc)
          post = Post.find_or_initialize_by_guid_namespace_and_guid(attributes)
          next unless post_is_valid?(post)
          warn "Unable to save post in #{self.class}: #{post.errors.full_messages.join(',')}" unless post.update_attributes(attributes)
          PostsOrigin.find_or_create_by_post_id_and_feed_key_and_source_key_and_source_id(post.id, @feed_key, @key, @source_id)
        end
        true
      end

      def filter_past_posts
        PostsOrigin.where(source_id: @source_id).includes(:post).find_each do |posts_origin|
          post = posts_origin.post
          posts_origin.destroy unless post_is_valid?(post)
        end
      end

      def post_is_valid?(post)
        return false if @options[:filter] && !@options[:filter].call(post)
        feed = Omnom.feeds[@feed_key]
        return false if feed.options[:filter] && !feed.options[:filter].call(post)
        true
      end

      def prepare_raw_posts(raw_posts)
        raw_posts.collect do |raw_post|
          if raw_post.is_a?(Nokogiri::XML::Element)
            raw_post.document.uri = @page.uri if raw_post.document.present? && raw_post.document.uri.blank? &&
              @page.present? && @page.uri.present?
          end
          raw_post
        end
      end

      # Proc#to_s returns an inconsistent value, and we need to convert Procs to strings using a consistent transformation
      def hash_to_consistent_string(hash)
        return hash unless hash.is_a?(Hash)
        hash = hash.dup
        hash.each do |key, value|
          hash[key] = value.source_location if value.is_a?(Proc)
        end
        hash.to_s
      end
    end
  end
end
