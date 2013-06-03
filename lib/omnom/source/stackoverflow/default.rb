module Omnom
  module Source
    module Stackoverflow
      class Default < Source::Base
        url 'http://stackoverflow.com/'
        every '5m'

        def after_initialize
          @url = "#{@url}#{@options[:path]}" if @options[:path].present?
        end

        def get_raw_posts
          @page.search('#questions > .question-summary')
        end

        def post_attributes(node)
          link_node = node.find('.question-hyperlink')
          url = link_node.url
          title = link_node.text
          guid = url

          author_link_node = node.find('.user-details').attr_matches('href', /^\/users\/\d+\//).first
          author_name = author_link_node.text
          author_url = author_link_node.url

          answers_count = node.find('.status > strong').text.to_i
          views_count = node.find('.views').text.to_i
          votes_count = node.find('.vote-count-post > strong').text.to_i

          {
            title: title,
            description: node.find('.excerpt').text,
            guid: guid,
            url: url,
            published_at: node.find('.relativetime').time(attribute: 'title'),
            author_name: author_name,
            author_url: author_url,
            comments_count: answers_count,
            comments_url: url,
            other: {
              answers_count: answers_count,
              views_count: views_count,
              votes_count: votes_count
            }
          }
        end
      end
    end
  end
end
