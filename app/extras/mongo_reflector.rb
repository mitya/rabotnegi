module MongoReflector
  def self.reflect(collection_key)
    @@klasses.detect { |klass| klass.key.to_s == collection_key.to_s } || Klass.new(collection_key.classify.constantize)
  end

  mattr_accessor :klasses
  @@klasses = []
  @@current_class = nil
  
  class Klass
    attr_accessor :reference, :list_fields, :details_fields

    def initialize(reference)
      @reference = reference
    end
    
    def searchable?
      reference.respond_to?(:query)
    end
    
    def key
      @reference.name.tableize
    end
    
    def reference_fields
      @reference_fields ||= reference.fields.
        reject { |key, mongo_field| key == '_type' }.
        map { |key, mongo_field| Field.new(key) }
    end
    
    def list_fields
      @list_fields || reference_fields
    end 
    
    def details_fields
      @details_fields || reference_fields
    end
  end
  
  class Field
    attr_accessor :name, :format, :klass

    def initialize(name, options = {})
      @name = name.to_s
      assign_attributes(options)
    end

    def title
      name
    end
    
    def inspect
      "<#{name}, format=#{format}>"
    end
  end
  
  class << self
    def desc(klass)
      @@current_klass = Klass.new(klass)
      @@klasses << @@current_klass
      yield
    end

    def list(*field_specs)          
      @@current_klass.list_fields = field_specs.map(&method(:convert_field_spec_to_object))
    end

    def details(*field_specs)
      @@current_klass.details_fields = field_specs.map(&method(:convert_field_spec_to_object))
    end

    def convert_field_spec_to_object(spec)
      if Array === spec
        format = spec.second
        spec = spec.first
      end

      field = Field.new(spec, format: format)
      field.klass = @@current_klass
      field
    end
  end
  
  desc Vacancy do
    list :id, :industry, :city, [:title, :link], :employer_name, :created_at
    details :id, :title, :city_name, :industry, :external_id, :employer_name, :created_at, :updated_at, :salary, :description
  end    

  desc User do
    list :id, :industry, :city, :ip_address, :browser, :created_at
  end

  desc Err do
    list :created_at, [:id, :link], :controller, :action, :url, :exception_class, :exception_message

    details :id,
      :created_at, :updated_at, 
      :controller, :action, :url, :host, :verb, 
      :exception_class, :exception_message,
      [:params, :hash], [:session, :hash], [:request_headers, :hash], [:response_headers, :hash], 
      [:backtrace, :pre]
  end  
end
