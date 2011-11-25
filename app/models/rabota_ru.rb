module RabotaRu
  autoload :VacancyLoader, "rabota_ru_vacancy_loader"
  autoload :VacancyConverter, "rabota_ru_vacancy_converter"

  def self.load
    RabotaRu::VacancyLoader.new.load
  end

  class VacancyLoading < ApplicationModel
    field :state
    field :details, type: Hash
    field :counts, type: Hash
    field :started_at, type: Time
    field :finished_at, type: Time    

    scope :reverse, order_by([:created_at, :desc])
    
    def initialize(*args)
      super
      self.counts ||= {}
      self.details ||= {}
    end
    
    def duration
      finished_at - started_at if finished_at && started_at
    end
    
    def finished?
      state == 'finished'
    end
    
    def self.model_name
      @model_name ||= ActiveModel::Name.new(self, RabotaRu)
    end
    
    def to_s
      "Загрузка от #{started_at.localtime.to_s(:number)}"
    end
  end
end
