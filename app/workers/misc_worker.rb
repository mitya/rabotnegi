module MiscWorker
  @queue = Se.default_queue

  def self.perform
    Rails.logger.info "Worker ping: disk.usage=#{M.disk_usage}% memory.free=#{M.memory_free}MB vacancy.count=#{Vacancy.count}"
  end
end
