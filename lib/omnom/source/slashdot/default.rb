module Omnom
  module Source
    module Slashdot
      class Default < Source::Base
        url 'http://slashdot.org/'
        every '5m'

        def get_raw_posts
          @page.search('#firehoselist > article')
        end

        def post_attributes(node)
          {
            title: node.search('h2.story > span > a').text,
            description: node.search('.body .p > i').inner_html.gsub(/^"|"$/, ''),
            guid: node.attr('data-fhid'),
            url: node.find('h2.story > span > a').attr('href'),
            published_at: node.find('.details time').time(time_zone: 'America/New_York'),
            thumbnail_url: node.find('header > .topic > a img').attr('src'),
            author_name: node.find('.details > a').text,
            author_url: node.find('.details > a').attr('href'),
            comments_count: node.drill([:find, 'footer a.read-more .comments'], :text, :to_i),
            comments_url: node.find('footer a.read-more').attr('href'),
            tags: node.search('.tag-bar .popular.tag').collect { |tag| tag.text }
          }
        end
      end
    end
  end
end
