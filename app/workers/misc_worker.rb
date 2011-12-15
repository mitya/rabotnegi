module MiscWorker
  @queue = DEFAULT_QUEUE

  def self.perform
    Rails.logger.info "Worker ping: disk.usage=#{mai.disk_usage}% memory.free=#{mai.memory_free}MB vacancy.count=#{Vacancy.count}"
  end
end
