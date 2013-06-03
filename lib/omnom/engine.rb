module Omnom
  class Engine < ::Rails::Engine
    isolate_namespace Omnom

    initializer 'omnom.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        #include Rails.application.routes.url_helpers
      end
    end

    initializer "omnom.load" do |app|
      Omnom.load
    end

    initializer "omnom.asset_pipeline", :group => :all do |app|
      app.config.assets.precompile << 'omnom/omnom.js'
      app.config.assets.precompile << 'omnom/omnom.css'
      app.config.assets.paths << Omnom.directory.join('..', 'app', 'assets', 'javascripts')
      app.config.assets.paths << Omnom.directory.join('..', 'app', 'assets', 'stylesheets')
    end

    # initializer :assets do |app|
    #   app.config.assets.paths << Omnom.directory.join('..', 'app', 'assets', 'javascripts')
    #   app.config.assets.paths << Omnom.directory.join('..', 'app', 'assets', 'stylesheets')
    #   Rails.application.config.assets.precompile += %w( omnom/omnom.js omnom/omnom.css )
    # end
  end
end