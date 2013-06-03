module Omnom
  class Reporting
    def self.warn_once(key, message)
      @warned_keys ||= []
      return if @warned_keys.include?(key)
      warn "[Omnom] #{message}"
      @warned_keys << key
    end
  end
end
