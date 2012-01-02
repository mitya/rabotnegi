class DemoWorker
  @queue = Se.default_queue
  
  def self.perform
    Rails.logger.info "--- DemoWorker.perform RAILS_PROC=#{ENV['RAILS_PROC']} RAILS_ENV=#{Rails.env}"
  end
end
