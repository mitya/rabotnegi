module MongoReflector
  class Metadata
    attr_reader :symbol
    
    def initialize(symbol)
      @symbol = symbol
    end
    
    def klass
      @klass ||= symbol.to_s.classify.constantize
    end
    
    def fields
      @fields ||= klass.fields.map{ |key, fld| fld }.map{ |fld| Field.new(fld.name, fld.options[:type]) }
    end
  end
  
  class Field
    attr_reader :name, :kind
    
    def initialize(name, kind)
      @name = name
      @kind = kind
    end
  end
end
