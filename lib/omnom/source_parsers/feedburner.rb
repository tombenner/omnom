module Omnom
  module SourceParsers
    module Feedburner
      def get_raw_posts
        @page.search('channel > item')
      end

      def post_attributes(node)
        node.document.root.add_namespace('feedburner', 'http://rssnamespace.org/feedburner/ext/1.0')
        link = node.>('feedburner|origLink').first
        link = node.>('link').first if link.blank?
        {
          title: node.>('title').first.text,
          description: node.>('description').first.text,
          guid: node.>('guid').first.text,
          url: link.text,
          published_at: node.>('pubDate').first.time,
          thumbnail_url: node.drill([:>, 'media|thumbnail'], :first, [:attr, 'url']),
          author_name: node.>('dc|creator').first.text,
          tags: node.>('category').map(&:text) - ['TC']
        }
      end
    end
  end
end
