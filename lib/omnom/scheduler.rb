module Omnom
  class Scheduler
    def self.start
      scheduler = Rufus::Scheduler.start_new
      initial_run_in_seconds = 0
      Omnom.feeds.values.each do |feed|
        next if feed.sources.blank?
        feed.sources.each do |source|
          method = source.settings.slice(:cron, :every).keys.first
          raise "Please specify a schedule for #{source.class.name}" if method.blank?
          value = source.settings[method]
          
          # For sources that run often, go ahead and run them now to update them with new posts
          if method == :every
            scheduler.in "#{initial_run_in_seconds}s" do
              safely_run("Update #{source.class} in #{feed.class}") do
                feed.update_source(source)
              end
            end
            initial_run_in_seconds += 15
          end

          scheduler.send(method, value) do
            safely_run("Update #{source.class} in #{feed.class}") do
              feed.update_source(source)
            end
          end
        end
      end
      scheduler
    end

    # If many jobs run at once, we may exhaust the pool. This catches database connection timeouts and retries
    # them after sleeping for a brief, random (to prevent multiple simultaneous queries) duration.
    def self.safely_run(name=nil)
      attempts = 10
      min_sleep_seconds = 3
      max_sleep_seconds = 5
      did_run = false

      attempts.times do
        begin
          yield
          did_run = true
          break
        rescue ActiveRecord::ConnectionTimeoutError => e
          sleep(rand(min_sleep_seconds..(max_sleep_seconds * 1.0)))
        end
      end
      unless did_run
        description = ": #{name}" if name
        warn "Unable to safely run task#{description}"
      end
    end
  end
end
