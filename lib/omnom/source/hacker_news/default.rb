module Omnom
  module Source
    module HackerNews
      class Default < Source::Base
        url 'https://news.ycombinator.com/'
        every '5m'

        def get_raw_posts
          first_title = @page.search('td.title').first
          table = first_title.ancestors('table').first
          rows = table.>('tr')
          row_sets = rows.each_slice(3).to_a.collect do |row_set|
            doc = Nokogiri::HTML(row_set.collect { |row| row.to_s }.join)
            doc.uri = @page.uri
            doc
          end
          row_sets
        end

        def post_attributes(node)
          title_node = node.find('td.title:eq(3)')
          meta_node = node.find('body > tr:eq(2) > td.subtext')
          
          return nil if title_node.blank?

          url = title_node.find('a').url
          published_at = meta_node.time

          author_link = meta_node.search('a').attr_matches('href', /^user\?id=/).first
          if author_link
            author_url = author_link.url
            author_name = author_link.text
          end

          comments_link = meta_node.search('a').text_matches(/(\d+) comments/).first
          if comments_link
            comments_count = comments_link.matches[1].to_i
            comments_url = comments_link.url
          else
            comments_count = 0
            comments_url = url
          end

          score_node = meta_node.search('span').attr_matches('id', /score_(\d+)/).first
          return nil if score_node.blank?

          points_count = score_node.text[/(\d+) points/, 1]
          points_count = points_count.to_i if points_count

          {
            title: title_node.find('a').text,
            guid: score_node.matches[1],
            url: url,
            published_at: published_at,
            author_name: author_name,
            author_url: author_url,
            comments_count: comments_count,
            comments_url: comments_url,
            other: {
              points_count: points_count
            }
          }
        end
      end
    end
  end
end
