require 'rails/generators'
require 'rails/generators/base'
 
module Omnom
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      
      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime('%Y%m%d%H%M%S').to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      desc 'Install config files'
      def install_config_files
        copy_file 'config/omnom.yml', 'config/omnom.yml'
        copy_file 'config/omnom.local.example.yml', 'config/omnom.local.example.yml'
      end

      desc 'Add config lines'
      def add_config_lines
        inject_into_file 'config/application.rb', "\n    config.from_file 'omnom.yml'\n\n", after: "Rails::Application\n"
        inject_into_file 'config/routes.rb', "\n  mount Omnom::Engine => '/'\n\n", after: "Application.routes.draw do\n"
      end

      desc 'Install the migrations'
      def install_migrations
        migration_template 'db/migrate/create_omnom_posts.rb', 'db/migrate/create_omnom_posts.rb'
        migration_template 'db/migrate/create_omnom_posts_origins.rb', 'db/migrate/create_omnom_posts_origins.rb'
      end
    end
  end
end