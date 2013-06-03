$:.push File.expand_path('../lib', __FILE__)
require 'omnom/version'

Gem::Specification.new do |s|
  s.name        = 'omnom'
  s.version     = Omnom::VERSION
  s.authors     = ['Tom Benner']
  s.email       = ['tombenner@gmail.com']
  s.homepage    = 'https://github.com/tombenner/omnom'
  s.summary = s.description = 'An everythingreader for programmers'

  s.files = Dir['{app,config,db,lib,vendor}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 3.2'
  s.add_dependency 'choices'
  s.add_dependency 'rufus-scheduler'
  s.add_dependency 'auto_strip_attributes', '~> 1.0'

  # Integration
  s.add_dependency 'mechanize'
  s.add_dependency 'nikkou'
  s.add_dependency 'therubyracer'
  s.add_dependency 'feedzirra'
  s.add_dependency 'fastimage'

  # Source Integration
  s.add_dependency 'legato'
  s.add_dependency 'oauth2'
  s.add_dependency 'twitter'

  # UI
  s.add_dependency 'haml'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'twitter-bootstrap-rails'
  s.add_dependency 'font-awesome-sass-rails'
  s.add_dependency 'truncate_html'

  # Development
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
end
