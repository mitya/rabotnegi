module MongoReflector
  def self.reflect(key)
    key = key.to_s
    @@klasses[key] || Klass.new(key.classify.constantize)
  end

  mattr_accessor :klasses
  @@klasses = {}
  @@current_class = nil
  
  class Klass
    attr_accessor :reference, :key, :list_fields, :details_fields, :list_order, :list_page_size

    def initialize(reference, options = {})
      @reference = reference
      @options = options
    end
    
    def searchable?
      reference.respond_to?(:query)
    end

    def key
      @options[:key] || @reference.model_name.plural
    end
    
    def plural
      @reference.model_name.plural
    end
    
    def singular
      @reference.model_name.singular
    end
    
    def reference_fields
      @reference_fields ||= reference.fields.
        reject { |key, mongo_field| key == '_type' }.
        map { |key, mongo_field| Field.new(key, klass: self) }
    end
    
    def list_fields
      @list_fields || reference_fields
    end 
    
    def details_fields
      @details_fields || reference_fields
    end
    
    def list_css_classes=(proc)
      @list_css_classes = proc
    end
    
    def list_css_classes(record)
      @list_css_classes ? @list_css_classes.call(record) : nil
    end
    
    def list_page_size
      @list_page_size || 30
    end
    
    def list_order
      @list_order || [:id, :asc]
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
    
    def i18n_title
      I18n.t("active_record.attributes.#{klass.singular}.#{name}", default: [:"active_record.attributes.common.#{name}", title])
    end
    
    def inspect
      "<#{name}, format=#{format}>"
    end
  end
  
  class << self
    def desc(reference, options = {})
      @@current_klass = Klass.new(reference, options)
      @@klasses[@@current_klass.key] = @@current_klass
      yield if block_given?
    end

    def list(*field_specs)          
      @@current_klass.list_fields = field_specs.map(&method(:convert_field_spec_to_object))
    end

    def details(*field_specs)
      @@current_klass.details_fields = field_specs.map(&method(:convert_field_spec_to_object))
    end
    
    def list_css_classes(&block)
      @@current_klass.list_css_classes = block
    end
    
    def list_order(value)
      @@current_klass.list_order = value
    end

    def list_page_size(value)
      @@current_klass.list_page_size = value
    end
    
  private

    def convert_field_spec_to_object(spec)
      if Array === spec
        format = spec.second
        spec = spec.first
      end

      Field.new(spec, format: format, klass: @@current_klass)
    end
  end

  desc Vacancy do
    list :id, :industry, :city, [:title, :link], :employer_name, :created_at
    details :id, :title, :city, :industry, :external_id, :employer_name, :created_at, :updated_at, :salary, :description
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
      [:params, 'inspect_hash'], [:session, 'inspect_hash'], [:request_headers, 'inspect_hash'], [:response_headers, 'inspect_hash'], 
      [:backtrace, :pre]
  end  

  desc MongoLog::Item, key: 'log_items' do
    list [:id, :link], :created_at, [:puid, 'color_code'], :title, [:duration, 'sec_usec'], [:brief, 'inspect_array_inline']
    list_css_classes { |x| {start: x.title == 'rrl.start', warning: x.warning?} }
    list_order [:_id, :desc]
    list_page_size 100
    details :id, :created_at, :puid, :title, :duration, [:brief, 'inspect_array'], [:data, 'inspect_hash']
  end
  
  desc RabotaRu::VacancyLoading, key: 'vacancy_loadings' do
    list [:id, :link], :created_at, :updated_at, :state, :details, :counts, :started_at, :finished_at
    list_css_classes { |x| {finished: x.finished?} }
    details :id, :created_at, :updated_at, :state, 
      [:duration, 'time'], [:details, 'inspect_hash'], [:counts, 'inspect_hash'], :started_at, :finished_at    
  end
end
