module Omnom
  module Source
    class Feed < Source::Base
      every '5m'
      required_options :url

      def after_initialize
        @settings[:icon] = self.class.icon_from_url(@options[:url]) if @settings[:icon].blank?
      end

      def get_raw_posts
        Feedzirra::Feed.fetch_and_parse(@options[:url]).entries
      end

      def post_attributes(entry)
        @entry = entry
        {
          title: title,
          description: description,
          guid: guid,
          url: url,
          published_at: published_at,
          author_name: author_name,
          tags: tags
        }
      end

      def title
        @entry.title
      end

      def description
        @entry.summary || @entry.content
      end

      def guid
        @entry.id
      end

      def url
        @entry.url
      end

      def published_at
        @entry.published
      end

      def author_name
        @entry.author
      end

      def tags
        @entry.categories
      end
    end
  end
end
