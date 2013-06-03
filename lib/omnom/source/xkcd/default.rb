module Omnom
  module Source
    module Xkcd
      class Default < Source::Base
        url 'http://xkcd.com/atom.xml'
        every '3h'

        def get_raw_posts
          @page.search('feed > entry')
        end

        def post_attributes(node)
          image_node = node.find('summary').parse_text.find('img')
          image_url = image_node.attr('src')
          url = node.find('link').url
          guid = url[/\/(\d+)\/$/, 1]
          {
            title: node.find('title').text,
            description: html_to_text(image_node.attr('title')),
            guid: guid,
            url: url,
            published_at: node.find('updated').time,
            thumbnail_url: image_url,
            author_name: 'Randall Munroe',
            author_url: 'http://xkcd.com/about/',
            other: {
              images: [{
                page_url: url,
                image_url: image_url  
              }]
            }
          }
        end
      end
    end
  end
end
