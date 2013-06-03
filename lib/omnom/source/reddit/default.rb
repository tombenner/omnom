module Omnom
  module Source
    module Reddit
      class Default < Source::Base
        url 'http://www.reddit.com/'
        every '5m'

        def after_initialize
          @url = "#{@url}#{@options[:subreddit]}" if @options[:subreddit].present?
        end

        def get_raw_posts
          @page.search('#siteTable > .link')
        end

        def post_attributes(node)
          thumbnail_node = node.find('a.thumbnail > img')
          thumbnail_url = thumbnail_node.attr('src') if thumbnail_node.present?

          comments_node = node.drill(
              [:find, '.flat-list.buttons'],
              [:text_matches, /^(\d+) comments$/i],
              :first
          )
          if comments_node
            comments_count = comments_node.matches[1]
            comments_url = comments_node.url
          else
            comments_node = node.drill(
              [:find, '.flat-list.buttons'],
              [:text_equals, 'comment'],
              :first
            )
            if comments_node
              comments_count = 0
              comments_url = comments_node.url
            end
          end

          title_node = node.find('p.title a.title')

          author_node = node.find('.tagline author')
          if author_node
            author_name = author_node.text
            author_url = author_node.url
          end

          {
            title: title_node.text,
            guid: node.attr('data-fullname'),
            url: title_node.url,
            published_at: node.find('.tagline time').time(attribute: 'datetime'),
            thumbnail_url: thumbnail_url,
            author_name: author_name,
            author_url: author_url,
            comments_count: comments_count,
            comments_url: comments_url,
            other: {
              likes_count: node.find('.score.unvoted').text.to_i
            }
          }
        end
      end
    end
  end
end
