module Omnom
  module Source
    module Techcrunch
      class Default < Source::Base
        include SourceParsers::Feedburner

        url 'http://feeds.feedburner.com/TechCrunch/'
        icon 'http://techcrunch.com/favicon.ico'
        every '5m'
      end
    end
  end
end
