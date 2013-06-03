module Omnom
  module Source
    module Github
      class Default < Source::Atom
        url config.atom if config && config.atom
        every '5m'
        required_config :atom

        def tags
          if @node.>('content').first.text =~ /^<!-- ([a-z]+) -->/
            return [$1]
          end
        end

        def description
          content = @node.>('content').first
          return if content.blank?
          if content.text.include?('<div class="details">')
            content = content.parse_text
            return content.find('.details').inner_html
          end
          nil
        end

        def thumbnail_url
          nil
        end
      end
    end
  end
end
