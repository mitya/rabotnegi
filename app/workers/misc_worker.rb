module MiscWorker
  @queue = DEFAULT_QUEUE

  def self.perform
    Rails.logger.info "Worker is still alive. disk.usage=#{mai.disk_usage}% vacancy.count=#{Vacancy.count}"
  end
end
