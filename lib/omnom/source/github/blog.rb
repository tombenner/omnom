module Omnom
  module Source
    module Github
      class Blog < Source::Atom
        url 'https://github.com/blog.atom'
        guid_namespace 'github__blog'
        every '5m'

        def author_url
          "https://github.com/#{author_name}"
        end
      end
    end
  end
end
