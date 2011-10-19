module LogFilter
   FILTERED_LOG_ENTRIES = [
     "SHOW FIELDS",
     "SET NAMES",
     "SET SQL_AUTO_IS_NULL",
     "Served asset",
     'Started GET "/assets/'
  ]

  class ::ActiveSupport::BufferedLogger
    alias add_without_filter add
    def add(severity, message = nil, progname = nil, &block)
      message = message.is_a?(String) ? message : message.inspect
      return if FILTERED_LOG_ENTRIES.any? { |filter_phrase| message.include?(filter_phrase) }
      add_without_filter(severity, message, progname, &block)
    end    
  end
end
