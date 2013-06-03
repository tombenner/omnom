module Omnom
  module Source
    class Atom < Source::Base
      every '5m'

      def after_initialize
        @settings[:icon] = self.class.icon_from_url(@options[:url]) if @settings[:icon].blank?
      end
      
      def get_raw_posts
        if @page.blank?
          Reporting.warn_once "Omnom.#{self.class}.get_raw_posts", "Unable to get page for Atom feed in #{self.class}"
          return nil
        end
        @page.search('feed > entry')
      end

      def post_attributes(node)
        @node = node
        {
          title: title,
          description: description,
          guid: guid,
          url: url,
          published_at: published_at,
          thumbnail_url: thumbnail_url,
          author_name: author_name,
          author_url: author_url,
          tags: tags
        }
      end

      def title
        @node.>('title').first.text
      end

      def description
        @node.>('content').first.text
      end

      def guid
        @node.>('id').first.text
      end

      def url
        @node.>('link').first.attr('href')
      end

      def published_at
        @node.>('published').first.time
      end

      def thumbnail_url
        @node.drill([:>, 'thumbnail'], :first, [:url, 'url'])
      end

      def author_name
        @node.find('author > name').text
      end

      def author_url
        @node.drill([:find, 'author > uri'], :text)
      end

      def tags
        nil
      end
    end
  end
end
