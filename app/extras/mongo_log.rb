module MongoLog
  class Writer
    attr_accessor :pkey
    attr_accessor :pid
    
    def initialize(pkey, pid)
      @pkey = pkey.to_s
      @pid = pid.to_s
    end

    def write(severity, name, params = [], data = {})
      Item.create!(name: name, pkey: @pkey, pid: @pid, severity: severity.to_s, params: params, data: data)
    end
    
    def info(name, *params)
      data = params.extract_options!
      write(:info, name, params, data)
    end

    def warn(name, *params)
      data = params.extract_options!
      write(:warn, name, params, data)
    end
  end
  
  class Item
    include Mongoid::Document
    
    store_in :log
    
    field :name
    field :severity
    field :pkey
    field :pid
    field :params, type: Array
    field :data, type: Hash

    def full_name
      "#{pkey.downcase}:#{name}"
    end
    
    def puid
      "#{pkey}-#{pid.presence || 'all'}"
    end
    
    def created_at
      id.generation_time
    end
  end
end
