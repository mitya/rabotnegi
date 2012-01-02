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
    
    # f("fixed1", "fixed2", conditional1: true, conditional2: false) => "fixed1 fixed2 conditional1"
    def css_classes_for(*args)
      return nil if args.empty?

      conditions = args.extract_options!
      classes = args.dup
      conditions.each { |clas, condition| classes << clas if condition }
      classes.join(" ")
    end
    
    def inspection(title, *args)
      options = args.extract_options!
      options.reject! { |k,v| v.blank? }
      options = options.map { |k,v| "#{k}=#{inspect_value(v)}" }.join(',')
      args = args.join(',')
      string = [args, options].reject(&:blank?).join(' ')
      # inspection = "#{title}(#{string})"
      inspection = "{#{string}}"
    end
    
    def inspect_value(value)
      case value
        when Proc then "Proc"
        else value
      end
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

  module Log
    def method_missing(selector, *args)
      Rails.logger.send(selector, *args)
    end
    
    def trace(*args)
      debug(*args)
    end
  end
  
  module DbLog
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
      Log.trace "U.http.get #{url}"
      Net::HTTP.get(URI.parse(url))
    end    
  end
  
  module Files
    def write(path, data = nil)
      Log.trace "U.files.write #{path}"
      File.open(path, 'w') { |file| file << data }
    end    
  end
  
  module Json
    def decode(data)
      ActiveSupport::JSON.decode(data)
    end    
  end

  extend self, Server, Strings, DbLog, Jobs, RandomHelpers
    
  attr :http, :files, :json, :db_log, :log
  @http = Object.new.extend(Http)
  @files = Object.new.extend(Files)
  @json = Object.new.extend(Json)
  @db_log = Object.new.extend(DbLog)
  @log = Object.new.extend(Log)
end

module Http
  extend self
  delegate :get, to: "Mai.http"
end

module Log
  extend self
  delegate :info, :error, :warn, :debug, :trace, to: "Mai.log"
end

def gg; Mai end
M = Mai
U = Mai
