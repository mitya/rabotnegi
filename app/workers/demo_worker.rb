class DemoWorker
  @queue = DEFAULT_QUEUE
  
  def self.perform
    Rails.logger.info "--- DemoWorker.perform RAILS_PROC=#{ENV['RAILS_PROC']} RAILS_ENV=#{Rails.env}"
  end
end
