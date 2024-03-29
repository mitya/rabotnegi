module MongoLog
  def self.write(puid, severity, title, brief = [], data = {})
    duration = Hash === data && data.delete(:duration)
    brief ||= []
    brief.map! { |param| param.respond_to?(:log_key) ? param.log_key : param }
    item = Item.create!(title: title, puid: puid, severity: severity.to_s, brief: brief, data: data, duration: duration)
    puts item.as_string if ENV['LOG_TO_CONSOLE']
  end
  
  class Writer
    attr_accessor :puid
    
    def initialize(puid)
      @puid = puid.to_s
    end

    def write(severity, title, *params)
      params = Array(params)
      data = params.last.is_a?(Hash) && params.last.delete(:env) || {}
      params.pop if params.last == {}
      MongoLog.write(@puid, severity, title, params, data)
    end
    
    def info(title, *params)
      write(:info, title, *params)
    end

    def warn(title, *params)
      write(:warn, title, *params)
    end
  end
  
  class Item < ApplicationModel
    store_in :log
    
    field :puid
    field :title
    field :severity
    field :duration, type: Float
    field :brief, type: Array
    field :data, type: Hash

    def created_at
      id.generation_time
    end
    
    def as_string
      "#{title} #{brief.inspect}"
    end
    
    def to_s
      "#{title} - #{puid} - #{created_at.localtime.to_s(:number)}"
    end
    
    def warning?
      severity == 'warn'
    end
    
    def self.query(options)
      return self unless options[:q].present?
      query = Regexp.new("^" + options[:q], true)
      any_of({title: query}, {puid: query})
    end
    
    def self.model_name
      @model_name ||= ActiveModel::Name.new(self, MongoLog)
    end    
  end
end
