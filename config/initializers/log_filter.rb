module LogFilter
  module MessagesToFilter
    extend self

    @@filtered_phrases = [
      "Session ID:",
      "SHOW FIELDS",
      "SET NAMES",
      "SET SQL_AUTO_IS_NULL",
      "Compiling template"
    ]
  
    def include?(message)
      @@filtered_phrases.any? { |filter_phrase| message.include?(filter_phrase) }
    end
  end

  module EagerLoadingFilter
    extend self
    def test?(message)
      message =~ /load including associations/i
    end
  
    def format(message)
      message.sub(/^.* load including associations/i, "SQL").sub(/SELECT .* FROM/, "SELECT * FROM")
    end 
  end

  module ExceptionsFilter
    extend self
    def test?(message, severity)
      severity == 4 && message.include?('script/server')
    end
  
    def format(message)
      lines = message.split("\n")
      methods = lines.grep(/^\s+.+in `.+$/)
      app_methods = lines.grep(/^\s+\/?(app|lib).+in `.+$/)
      first_method = lines.index(methods.first)
    
      result = lines[1...first_method]
      result << "App Methods:" if app_methods.any?
      result.concat(app_methods)
      result << "Last 5:"
      result.concat(methods.first(5))
      result << ""
      result << ""
    
      result.join("\n")
    end  
  end
  
  class ::ActiveSupport::BufferedLogger
    alias add_without_filter add
    def add(severity, message = nil, progname = nil, &block)
      message = message.is_a?(String) ? message : message.inspect
  
      return if MessagesToFilter.include?(message)
  
      message = ExceptionsFilter.format(message) if ExceptionsFilter.test?(message, severity)
      message = EagerLoadingFilter.format(message) if EagerLoadingFilter.test?(message)
  
      add_without_filter(severity, message, progname, &block)
    end    
  end
end