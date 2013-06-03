require 'omnom/source/github/blog'

module Omnom
  module Source
    module Github
      class BlogSection < Blog
        guid_namespace 'github__blog'
        every '5m'
        required_options :section

        def after_initialize
          sections = {
            broadcasts: 'https://github.com/blog/broadcasts.atom',
            meetups: 'https://github.com/blog/drinkup.atom',
            enterprise: 'https://github.com/blog/enterprise.atom',
            new_features: 'https://github.com/blog/ship.atom',
            engineering: 'https://github.com/blog/engineering.atom',
            watercooler: 'https://github.com/blog/watercooler.atom'
          }
          @url = sections[@options[:section]]
        end
      end
    end
  end
end
