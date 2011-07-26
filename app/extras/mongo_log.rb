module MongoLog
  def self.write(puid, severity, title, brief = [], data = {})
    item = Item.create!(title: title, puid: puid, severity: severity.to_s, brief: brief, data: data, duration: data.delete(:duration))
    puts item.as_string if ENV['LOG_TO_CONSOLE']
  end
  
  class Writer
    attr_accessor :puid
    
    def initialize(puid)
      @puid = puid.to_s
    end

    def write(severity, title, brief = [], data = {})
      MongoLog.write(@puid, severity, title, brief, data)
    end
    
    def info(title, *params)
      write(:info, title, params, params.extract_options!)
    end

    def warn(title, *params)
      write(:warn, title, params, params.extract_options!)
    end
  end
  
  class Item
    include Mongoid::Document
    
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
    
    def warning?
      severity == 'warn'
    end
    
    def self.search(query)
      return self unless query.present?
      
      query = Regexp.new("^" + query, true)
      any_of({title: query}, {puid: query})
    end
  end
end
