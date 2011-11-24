module MongoReflector
  def self.reflect(collection_key)
    Metadata.new(collection_key)
  end
  
  class Metadata
    attr_reader :symbol
    
    def initialize(symbol)
      @symbol = symbol
    end
    
    def klass
      @klass ||= symbol.to_s.classify.constantize
    end
    
    def searchable?
      klass.respond_to?(:query)
    end
    
    def fields
      @fields ||= custom_fields || all_fields
    end
    
    def all_fields
      klass.fields.map{ |key, fld| fld }.map{ |fld| Field.new(fld.name, fld.options[:type]) }
    end
    
    def custom_fields
      selected_fields = DATA.detect{ |k, fields| k == klass }.try(:second)      
      return nil unless selected_fields
            
      selected_fields.map do |fld_name|
        mongo_field = klass.fields[fld_name.to_s]
        mongo_field ? Field.new(mongo_field.name, mongo_field.options[:type]) : Field.new(fld_name)
      end
    end
  end
  
  class Field
    attr_reader :name, :kind
    
    def initialize(name, kind = nil)
      @name = name.to_s
      @kind = kind
    end
    
    def title
      name.titleize
    end
  end
  
  
  DATA = [
    [Vacancy, [:id, :industry, :city, :title, :employer_name, :created_at]],
    [User, [:id, :industry, :city, :ip_address, :browser, :created_at]],
    [Err, [:created_at, :id, :controller, :action, :url, :exception_class, :exception_message]]
  ]  
end
