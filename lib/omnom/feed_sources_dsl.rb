module Omnom
  class FeedSourcesDSL
    attr_reader :sources

    def self.create_source_method(source)
      settings_keys = [:cron, :every, :filter]

      method = class_to_method(source)
      
      define_method(method, Proc.new { |*args|
        if args.present?
          args = args.first
          settings = args.slice(settings_keys)
          options = args.except(settings_keys)
        end
        @sources << source.new(settings, options)
      })
    end

    def self.class_to_method(klass)
      klass.key
    end

    def initialize(&block)
      @sources = []
      instance_eval(&block)
    end
  end
end
