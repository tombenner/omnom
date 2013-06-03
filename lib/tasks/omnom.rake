namespace :omnom do
  desc 'Start Omnom\'s background processing'
  task :scheduler => :environment do
    scheduler = Omnom::Scheduler.start
    scheduler.join
  end

  desc 'Update all Omnom feeds'
  task :update => :environment do
    Omnom.feeds.values.each do |feed|
      feed.update
    end
  end
end