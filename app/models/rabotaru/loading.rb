module Rabotaru
  class Loading
    include Mongoid::Document
        
    field :city
    field :industry
    field :state, type: Symbol, default: 'created'
    field :error, type: String
    
    embedded_in :job, class_name: 'Rabotaru::Job'
    validates_presence_of :city, :industry
    def_state_predicates 'state', :created, :queued, :started, :done, :skipped, :failed
    
    def queue
      mark :queued
      Mu.enqueue(Rabotaru, :load_vacancies, job.id, id)
    end

    def run
      mark :started
      loader = Loader.new(city, industry)
      loader.load
      mark :done
    rescue => e
      Err.register("Rabotaru::Loading.run", e, params: {city: city, industry: industry})
      mark :failed, error: gg.format_error(e)
    end
    
    # def updated_at
    #   self.class._states.map { |state| send("#{state}_at") }.compact.max
    # end
    
    def inspect(*args)
      Mu.inspection(self, state, city, industry)
    end
    
    def to_s
      inspect
    end
  end
end
