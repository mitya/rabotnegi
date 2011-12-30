module MongoReflector
  def self.reflect(key)
    key = key.to_s
    @@klasses[key] || Klass.new(key.classify.constantize)
  end

  mattr_accessor :klasses
  @@klasses = {}
  @@current_class = nil
  
  class Klass
    attr_accessor :reference, :key, :list_fields, :details_fields, :list_order, :list_page_size, :edit_fields

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
      @list_order || [:_id, :desc]
    end
    
    def edit_fields
      @edit_fields
    end
  end
  
  class Field
    attr_accessor :name, :format, :klass, :args, :options

    def initialize(name, options = {})
      @name = name.to_s
      assign_attributes!(options)
    end
    
    def title
      name = @name.gsub('.', '_')
      I18n.t("active_record.attributes.#{klass.singular}.#{name}", default: [:"active_record.attributes.common.#{name}", name.to_s.humanize])
    end
    
    def custom?
      format.is_a?(Proc)
    end
    
    def options=(hash)
      @options ||= ActiveSupport::OrderedOptions.new
      @options.merge!(hash) if hash
    end
    
    def options
      @options || ActiveSupport::OrderedOptions.new
    end
    
    def css
      css = []
      # css << options[:css] if options
      css << options.css if options
      css << 'wide' if format.in?([:hash, :pre])
      css.join(' ')
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
      field_specs = field_specs.first.to_a if Hash === field_specs.first
      @@current_klass.list_fields = field_specs.map(&method(:convert_field_spec_to_object))
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

    def details(*field_specs)
      field_specs = field_specs.first.to_a if Hash === field_specs.first      
      @@current_klass.details_fields = field_specs.map { |s| convert_field_spec_to_object(s) }
    end

    def edit(field_specs)
      @@current_klass.edit_fields = field_specs.map do |key, spec|
        if Array === spec
          helper = spec.shift
          args = spec
        else
          helper = spec
          args = []
        end
        Field.new(key, format: helper, args: args, klass: @@current_klass)
      end
    end
    
    private

    def convert_field_spec_to_object(spec)
      # :name
      # :name, :format, option1: 'value1'
      # :name, [:format, option1: 'value1']
      if Array === spec
        spec.flatten! if Array === spec.second
        name = spec.first
        options = spec.extract_options!
        format = spec.second        
      else
        name = spec        
      end

      Field.new(name, format: format, klass: @@current_klass, options: options)
    end
  end

  _ = nil

  desc Vacancy do
    list :id, :industry, :city, [:title, :link], :employer_name, :created_at
    details :id, :title, :city, :industry, :external_id, :employer_name, :created_at, :updated_at, :salary, :description
    
    edit \
      title: 'text', 
      city_name: ['combo', City.all], industry_name: ['combo', Industry.all],
      external_id: 'text',
      employer_id: 'text', employer_name: 'text',
      created_at: 'date_time', updated_at: 'date_time',
      description: 'text_area'      
  end    

  desc User do
    list :id, :industry, :city, :ip_address, :browser, :created_at
  end

  desc Err do
    list created_at: _, id: :link, source: _, 
      url: [trim: 40],
      exception: [ ->(err) { "#{err.exception_class}: #{err.exception_message}" }, trim: 100 ]

    details \
      id: _, created_at: _, host: _, source: _, 
      url: ->(err) { "#{err.verb} #{err.url}" },
      exception: ->(err) { "#{err.exception_class}: #{err.exception_message}" },
      params: 'hash_view',
      session: 'hash_view', request_headers: 'hash_view', response_headers: 'hash_view', backtrace: :pre
  end

  desc MongoLog::Item, key: 'log_items' do
    list id: :link, created_at: _, puid: 'color_code', title: _, duration: 'sec_usec', brief: 'array_inline'
    list_css_classes { |x| {start: x.title == 'rrl.start', warning: x.warning?} }
    list_page_size 100
    details :id, :created_at, :puid, :title, :duration, [:brief, 'array_view'], [:data, 'hash_view']
  end
  
  desc RabotaRu::Job, key: 'rabotaru_jobs' do
    list [:id, :link], :state, :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :failed_at
    list_css_classes { |x| { processed: x.processed?, loaded: x.loaded?, failed: x.failed? } }
    details :id, :state, 
      :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :failed_at,
      "loadings.count"
      
    # embed_list :rabotaru_loadings, key: 'job_id'
  end

  desc RabotaRu::Job, key: 'rabotaru_loadings' do
    list [:id, :link], :state, :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :failed_at
    list_css_classes { |x| { processed: x.processed?, loaded: x.loaded?, failed: x.failed? } }
    details :id, :state, 
      :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :failed_at,
      "loadings.count"
      
    # embed_list :rabotaru_loadings, key: 'job_id'
  end
end
