module Omnom
  module ParserMethods
    def html_to_text(html)
      # Nokogiri transforms &nbsp; to &#xa0; or \u00a0
      Nokogiri::HTML(html).text.gsub('&#xa0;', ' ').gsub(/\u00a0/, ' ')
    end
  end
end
