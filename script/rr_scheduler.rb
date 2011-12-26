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
PERIOD = 10

queue = City.all.product(Industry.all).map { |city, industry| 
  RabotaRu::Loading.new(city: city.key, industry: industry.key)
}
current = queue.shift
job = RabotaRu::Job.create!

def wait(timeout = PERIOD)
  sleep(timeout)
end

loop do
  job.reload
  current.reload if current && current.queued?
  qq.debug "rr_scheduler: current.state=#{current.try(:state)} job.loadings.count=#{job.loadings.count}"
  case when current == nil
    job.mark :loaded
    job.queue_processing
    break
  when current.created?
    job.loadings << current
    current.queue
    wait
  when current.queued?
    wait
    if Time.now - current.started_at > 20.minutes
      current.mark :failed, error: "Skipped after timeout"
      current = queue.deq
    end
  when current.failed?
    if job.loadings.select(&:failed?).count > 3
      job.mark :failed
      break
    end
    current = queue.shift
  when current.done?
    time_since_done = Time.now - current.done_at
    current = queue.shift
    wait(PERIOD - time_since_done) if time_since_done < PERIOD
  end
end
