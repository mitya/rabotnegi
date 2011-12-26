module RabotaRu
  class Job < ApplicationModel
    field :state, type: Symbol, default: 'started'
    embeds_many :loadings, class_name: 'RabotaRu::Loading'
    def_state_predicates 'state', :started, :failed, :loaded, :processed

    def queue_processing
      gg.enqueue(self.class, :process, id)
    end

    def self.process(job_id)
      job = find(job_id)
      # RabotaRu::VacancyProcessor.new.process
      job.mark :processed
    end
  end

  class Loading
    include Mongoid::Document
        
    field :city
    field :industry
    field :state, type: Symbol, default: 'created'
    field :error, type: String
    
    embedded_in :job, class_name: 'RabotaRu::Job'
    validates_presence_of :city, :industry
    def_state_predicates 'state', :created, :queued, :done, :skipped, :failed
    
    def queue
      mark :queued
      gg.enqueue(self.class, :perform, job.id, id)
    end

    def run
      mark :started
      loader = VacancyLoader.new(city, industry)
      loader.load
      mark :done
    rescue => e
      Err.register("RabotaRu::Loading.run", e, params: {city: city, industry: industry})
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
        
    def self.perform(job_id, loading_id)
      job = Job.get(job_id)
      loading = job.loadings.find(loading_id)
      loading.run
    end    
  end
end
