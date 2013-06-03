require 'omnom/source/reddit/default'

module Omnom
  module Source
    module Reddit
      class Images < Omnom::Source::Reddit::Default
        def post_attributes(node)
          attributes = super
          if attributes[:url] =~ /(?:.bmp|.gif|.jpeg|.jpg|.png|.tiff)$/
            images = [{
              page_url: attributes[:url],
              image_url: attributes[:url]
            }]
          elsif attributes[:url] =~ /http:\/\/imgur.com\/\w{3,}$/ || attributes[:url] =~ /http:\/\/imgur.com\/a\/\w{3,}$/
            images = get_imgur_images(attributes[:url])
          end
          return nil unless images
          attributes[:other][:images] = images
          attributes
        end

        def get_imgur_images(url)
          page = @agent.get(url)
          return nil if page.blank?
          image_nodes = page.search('.panel .image a > img')
          image_nodes.collect do |image_node|
            {
              page_url: url,
              image_url: image_node.attr('src') || image_node.attr('data-src')
            }
          end
        end
      end
    end
  end
end
