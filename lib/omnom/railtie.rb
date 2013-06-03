module Omnom
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir.glob(Omnom.directory.join('tasks', '*.rake')).each { |f| load f }
    end
  end
end
