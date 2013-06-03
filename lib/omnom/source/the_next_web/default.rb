module Omnom
  module Source
    module TheNextWeb
      class Default < Source::Base
        include SourceParsers::Feedburner

        url 'http://feeds2.feedburner.com/thenextweb'
        icon 'http://thenextweb.com/favicon.ico'
        every '5m'

        def post_attributes(node)
          attributes = super
          if attributes[:description].present?
            attributes[:description] = html_to_text(attributes[:description])
            attributes[:description].sub!(/\s+Keep reading .\s*$/, '')
          end
          attributes
        end
      end
    end
  end
end
