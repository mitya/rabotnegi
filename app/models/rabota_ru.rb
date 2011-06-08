# coding: utf-8

module RabotaRu
  autoload :VacancyLoader, "rabota_ru_vacancy_loader"
  autoload :VacancyConverter, "rabota_ru_vacancy_converter"

  def self.load
    RabotaRu::VacancyLoader.new.load
  end

  class VacancyLoading
    include Mongoid::Document
    include Mongoid::Timestamps

    field :state
    field :details, type: Hash
    field :counts, type: Hash

    field :started_at, type: Time
    field :finished_at, type: Time    
    
    def initialize(*args)
      super
      self.counts ||= {}
      self.details ||= {}
    end
  end
end
