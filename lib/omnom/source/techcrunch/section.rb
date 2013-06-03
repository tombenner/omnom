require 'omnom/source/techcrunch/default'

module Omnom
  module Source
    module Techcrunch
      class Section < Default
        every '5m'
        required_options :section
        icon 'http://techcrunch.com/favicon.ico'

        def after_initialize
          sections = {
            startups: 'http://feeds.feedburner.com/TechCrunch/startups',
            funding_and_exits: 'http://feeds.feedburner.com/TechCrunch/fundings-exits',
            social: 'http://feeds.feedburner.com/TechCrunch/social',
            mobile: 'http://feeds.feedburner.com/Mobilecrunch',
            gadgets: 'http://feeds.feedburner.com/crunchgear',
            gaming: 'http://feeds.feedburner.com/TechCrunch/startups',
            europe: 'http://feeds.feedburner.com/Techcrunch/europe',
            enterprise: 'http://feeds.feedburner.com/TechCrunchIT',
            greentech: 'http://feeds.feedburner.com/TechCrunch/greentech'
          }
          @url = sections[@options[:section]]
        end
      end
    end
  end
end
