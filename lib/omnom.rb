require 'auto_strip_attributes'
require 'choices'
require 'rufus/scheduler'

require 'mechanize'
require 'nikkou'
require 'v8'
require 'feedzirra'
require 'fastimage'

require 'legato'
require 'oauth2' # Required for Legato
require 'twitter'

require 'haml'
require 'coffee-rails'
require 'jquery-rails'
require 'sass-rails'
require 'twitter-bootstrap-rails'
require 'font-awesome-sass-rails'
require 'truncate_html'

module Omnom
  def self.add_feed(feed)
    feeds[feed.key] = feed
  end

  def self.add_source(source)
    sources[source.key] = source
  end

  def self.feeds
    @feeds ||= {}
  end

  def self.sources
    @sources ||= {}
  end

  def self.active_sources
    feeds.values.collect { |feed| feed.sources }.flatten.compact
  end

  def self.config
    begin
      return Rails.configuration.omnom
    rescue NoMethodError
      Reporting.warn_once 'Omnom.config', 'Please make sure that omnom.yml has been installed and has configuration for Omnom'
    end
    nil
  end

  def self.table_name_prefix
    'omnom_'
  end

  def self.directory
    Pathname.new(File.dirname(File.absolute_path(__FILE__)))
  end

  def self.load
    require_glob(directory.join('omnom', 'source_parsers', '**', '*.rb'))
    require_glob(directory.join('omnom', 'source', 'base.rb'))
    require_glob(directory.join('omnom', 'source', 'atom.rb'))
    require_glob(directory.join('omnom', 'source', '**', '*.rb'))
    require_glob(Rails.root.join('lib', 'omnom', 'source', '**', '*.rb'))
    require_glob(Rails.root.join('app', 'feeds', '**', '*.rb'))

    configure
    instantiate_feeds
    start_scheduler if config.present? && config.run_scheduler_on_web_server && is_server_being_run? && is_database_ready?
  end

  def self.is_server_being_run?
    defined?(Rails) && Rails.const_defined?('Server')
  end

  def self.is_database_ready?
    is_ready = Omnom::Post.table_exists? && Omnom::PostsOrigin.table_exists?
    Reporting.warn_once 'Omnom.is_database_ready?', 'Database migrations for Omnom have not been run' unless is_ready
    is_ready
  end

  def self.start_scheduler
    Omnom::Scheduler.start
  end

  def self.instantiate_feeds
    feeds.each do |key, feed_class|
      feeds[key] = feed_class.new
    end
  end

  def self.configure
    sources.each do |key, source|
      source.configure
    end
  end

  def self.require_glob(path)
    Dir.glob(path) { |file| require file }
  end
end

Omnom.require_glob(Omnom.directory.join('omnom', '*.rb'))