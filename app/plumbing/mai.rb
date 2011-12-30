require 'net/http'

module Mai
  module RandomHelpers
    def unescape_action_mailer_stuff(string)
      string.gsub("&#47;", '/').gsub("&amp;", '&')    
    end    
    
    def id(array)
      results = array ? array.map(&:id) : []
      results = results.map(&:to_s) if results.first.is_a?(BSON::ObjectId)
      results
    end
    
    def logger
      Rails.logger
    end
  end
  
  module Jobs
    def enqueue(klass, method, *args)
      # Resque.enqueue_to(:main, ProxyWorker, args)
      Rails.logger.info "Scheduled job #{klass}.#{method}#{args.inspect}"
      Resque::Job.create('main', 'Mai::Jobs::Worker', klass.to_s, method.to_s, args)
    end

    class Worker
      def self.perform(klass, method, args)
        Rails.logger.info "Started job #{klass}.#{method}#{args.inspect}"
        klass.constantize.send(method, *args)
        Rails.logger.info "Completed job #{klass}.#{method}#{args.inspect}"
      end
    end
  end
  
  module Strings
    def interpolate(template, replacements = {})
      replacements.inject(template) { |result, (key, value)| result.sub("{#{key}}", value.to_s) }
    end
  
    def time_stamp
      time = Time.current
      time.strftime("%Y%m%d_%H%M%S_#{time.usec}")
    end
    
    def date_stamp
      time = Time.current
      time.strftime("%Y%m%d")
    end
  
    def format_error(exception)
      "#{exception.class} - #{exception.message}"
    end

    def format_error_and_stack(exception)
      format_error(exception) + "\n#{exception.backtrace.join("\n")}"
    end
  end
    
  module Server
    def disk_usage(mount_point = '/')
      output = `df #{mount_point}`
      lines = output.split("\n")
      value = lines.second.split.at(-2).to_i
      value
    rescue
      nil
    end
  
    def memory_free
      output = `free -m`
      lines = output.split("\n")
      value = lines.second.split.at(3).to_i
      value
    rescue 
      nil
    end    
  end

  module Logging
    def write(severity, message, *args)
      data = args.extract_options!
      brief = args.shift if args.first.is_a?(Array)
      MongoLog.write(nil, severity, message, brief, data)      
    end
    
    def info(message, *args)
      write(:info, message, *args)
    end
    
    def alert(message, *args)
      write(:error, message, *args)
    end
    
    def event(key, data = {})
      info("event registered: #{key}", data)
    end
  end

  module Http
    def get(url)
      gg.logger.debug "qq.http.get #{url}"
      Net::HTTP.get(URI.parse(url))
    end    
  end
  
  module Files
    def write(path, data = nil)
      gg.logger.debug "qq.files.write #{path}"      
      File.open(path, 'w') { |file| file << data }
    end    
  end
  
  module Json
    def decode(data)
      ActiveSupport::JSON.decode(data)
    end    
  end

  extend self, Server, Strings, Logging, Jobs, RandomHelpers
    
  attr :http, :files, :json
  @http = Object.new.extend(Http)
  @files = Object.new.extend(Files)
  @json = Object.new.extend(Json)
end

module Http
  extend self
  delegate :get, to: "Mai.http"
end

module Log
  extend self
  delegate :info, :alert, :event, to: "Mai"
end

def gg; Mai end
def M; Mai end
