module Omnom
  class Feed
    class << self
      def inherited(child)
        Omnom.add_feed(child)
      end

      def options
        @options ||= {key: self.key}
      end

      def filter(&block)
        options[:filter] = block
      end

      def sources(&block)
        config = FeedSourcesDSL.new(&block)
        options[:sources] = config.sources
      end

      def template(template)
        options[:template] = template
      end

      def key
        name.underscore.gsub('/', '__')
      end
    end

    attr_reader :options

    def initialize
      @options = self.class.options
    end

    def key
      self.class.key
    end

    def title
      key.gsub(/_feed$/, '').humanize
    end

    def template
      @options[:template] || :default
    end

    def posts
      source_ids = sources.collect(&:source_id)
      Post.includes(:posts_origins).where(
        'omnom_posts_origins.feed_key' => key,
        'omnom_posts_origins.source_id' => source_ids
      )
    end

    def update
      sources.each do |source|
        source.update
      end
    end

    def update_by_source_key(source_key=nil)
      if source_key
        source = source_by_source_key(source_key)
        raise "Source with source key '#{source_key}' not found in feed #{self.class}" and return if source.nil?
        source.update
      else
        return if sources.nil?
        sources.each(&:update)
      end
    end

    def update_source(source)
      source.update
    end

    def sources
      if @options[:sources]
        @options[:sources].each do |source|
          source.feed_key = key
        end
      end
      @options[:sources]
    end

    def source_by_source_id(source_id)
      source_id = source_id.to_s
      sources.each do |source|
        return source if source.source_id == source_id
      end
      nil
    end

    def source_by_source_key(source_key)
      source_key = source_key.to_s
      sources.each do |source|
        return source if source.key == source_key
      end
      nil
    end
  end
end
