#!/usr/bin/env ruby

require 'pp'
# require 'daemons'
# require 'optparse'
# 
rails_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
ENV['RAILS_PROC'] = 'worker-rr'
# 
# id = ARGV.shift
# raise("Numeric ID should be given as the first argument") unless id.to_i > 0
# 
# Daemons.run_proc("resque.#{id}", dir: File.join(rails_root, "tmp/pids"), dir_mode: :normal, log_output: true, log_dir: File.join(rails_root, "log")) do
#   Dir.chdir(rails_root)
#   require File.join(rails_root, "config/environment")
#   worker = Resque::Worker.new("*")
#   worker.verbose = true
#   worker.work(5)
# end

require File.join(rails_root, "config/environment")
PERIOD = 0.1

queue = City.all.product(Industry.all).map { |city, industry| 
  RabotaRu::LoadingItem.new(city: city.key, industry: industry.key)
}
current = queue.shift
memo = RabotaRu::Loading.create!

def wait(timeout = PERIOD)
  sleep(timeout)
end

loop do
  memo.reload
  current.reload if current && current.queued?
  puts "tick #{current.try(:state)}"
  case when current == nil
    puts "all done"
    memo.mark :loaded
    memo.queue_processing
    break
  when current.created?
    memo.items << current
    current.queue
    wait
  when current.queued?
    wait
    if Time.now - current.started_at > 20.minutes
      current.mark :failed, error: "Skipped after timeout"
      current = queue.deq
    end
  when current.failed?
    if memo.items.select(&:failed?).count > 3
      memo.mark :failed
      break
    end
    current = queue.shift
  when current.done?
    time_since_done = Time.now - current.done_at
    current = queue.shift
    wait(PERIOD - time_since_done) if time_since_done < PERIOD
  end
end
