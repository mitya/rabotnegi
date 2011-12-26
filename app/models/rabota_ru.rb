module RabotaRu
  class LoadingItem
    include Mongoid::Document
        
    field :city
    field :industry
    field :state, type: Symbol, default: 'created'
    field :error, type: String
    
    embedded_in :loading, class_name: 'RabotaRu::Loading'
    validates_presence_of :city, :industry
    def_state_predicates 'state', :created, :queued, :done, :skipped, :failed
    
    def queue
      mark :queued
      puts "queue #{self}"
      gg.enqueue(RabotaRu::LoadingItem, :perform, loading.id, id)
    end

    def run
      mark :started
      loader = VacancyLoader.new(city: city, industry: industry)
      # loader.load
      mark :done
    rescue => e
      Err.register("LoadingItem.run", e, params: {city: city, industry: industry})
      mark :failed, error: gg.format_error(e)
    end
    
    def inspect(*args)
      "LoadingItem(#{state}, #{city}, #{industry})"
    end
    
    def to_s
      inspect
    end
    
    # def self.model_name
    #   @model_name ||= ActiveModel::Name.new(self, RabotaRu)
    # end
        
    def self.perform(loading_id, item_id)
      loading = Loading.get(loading_id)
      item = loading.items.find(item_id)
      item.run
    end    
  end

  class Loading < ApplicationModel
    field :state, type: Symbol, default: 'started'
    embeds_many :items, class_name: 'RabotaRu::LoadingItem'
    def_state_predicates 'state', :started, :failed, :loaded, :done

    def queue_processing
      gg.enqueue(self.class, :process)
    end

    def self.process(loading_id)
      loading = find(loading_id)
      RabotaRu::VacancyProcessor.new.process
      loading.mark :done
    end
  end
end
