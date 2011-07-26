module Mai
  module_function
  
  def write_file(path, data)
    File.open(path, 'w') { |file| file << data }
  end
  
  def http_get(host, url)
    Net::HTTP.get(host, url)
  end
  
  def decode_json(data)
    ActiveSupport::JSON.decode(data)
  end
  
  def interpolate(template, replacements = {})
    replacements.inject(template) { |result, (key, value)| result.sub("{#{key}}", value.to_s) }
  end
  
  def timestamp_string
    time = Time.current
    time.strftime("%Y%m%d_%H%M%S_#{time.usec}")
  end
  
  def format_error(exception)
    "#{e.class} - #{e.message}"
  end  
  
  def id(array)
    array.map(&:id) if array
  end
  
  def subscribe(event_pattern)
    ActiveSupport::Notifications.subscribe(event_pattern) do |event_name, started, ended, event_id, payload|
      yield Event.new(event_name, started, ended, event_id, payload)
    end    
  end
  
  def subscribe_all(namespace, events, &block)
    subscribe(/#{namespace}\.(#{events.join('|')})/, &block)
  end
  
  class Event
    attr_accessor :title, :started, :ended, :id, :data, :severity, :puid, :brief, :writer
    delegate :memo, :memo=, :to => :writer, :allow_nil => true
    
    def initialize(title, started, ended, id, payload)
      @title = title
      @started = started
      @ended = ended
      @id = id
      @payload = payload
      @data = @payload.except(:severity, :puid, :brief, :writer)
      @severity = @payload[:severity]
      @puid = @payload[:puid]
      @brief = @payload[:brief]
      @writer = @payload[:writer]
    end
    
    def duration
      @ended - @started
    end    
    
    def method_missing(method, *args)
      @payload.include?(method) ? @payload[method] : super
    end
  end
  
  class EventWriter
    attr_accessor :namespace, :puid, :memo, :options
    
    def initialize(namespace, pid, options = {})
      @namespace = namespace
      @puid = "#{namespace}_#{pid}"
      @options = options
    end
    
    def write(severity, event, brief = [], data = {}, &block)
      @last_payload = data.merge(brief: brief, severity: severity, puid: puid, writer: self).merge(options)
      ActiveSupport::Notifications.instrument("#{namespace}.#{event}", @last_payload, &block)
    end
    
    def info(event, *params, &block)
      write(:info, event, params, params.extract_options!, &block)
    end

    def warn(event, *params, &block)
      write(:warn, event, params, params.extract_options!, &block)
    end
    
    def results(*params)
      @last_payload.merge!(params.extract_options!)
      @last_payload[:brief].concat(params)
    end
  end
end