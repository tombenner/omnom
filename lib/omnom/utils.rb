module Omnom
  module Utils
    def self.clean_url(url)
      url = url.to_s
      return "http:#{url}" if url.start_with?('//')
      return "http://#{url}" if url !~ /https?:\/\//
      url
    end
  end
end
