class DemoWorker
  @queue = :main
  
  def self.perform(argument)
    Rails.logger.info "DemoWorker.perform(argument=#{argument}) at #{Time.now}"
    MongoLog.write(nil, :info, 'demo.perform', [argument], time: Time.now)
  end
end
