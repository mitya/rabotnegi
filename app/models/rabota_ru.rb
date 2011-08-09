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
  end
  
  def self.prepare
    mai.subscribe_all :rrl, %w(start load convert convert.fail filter filter save finish) do |e|
      MongoLog.write(e.puid, e.severity, e.title, e.brief, e.data.merge(duration: e.duration))
    end

    mai.subscribe 'rrl.start' do |e|
      e.writer.memo = RabotaRu::VacancyLoading.create!(started_at: Time.current, state: "started")
    end

    mai.subscribe 'rrl.finish' do |e|
      e.memo.update_attributes!(state: "finished", finished_at: Time.current)
    end

    # mai.subscribe 'rrl.filter.done' do |e|
    #   e.memo.counts[:new] = e.data.new.size
    #   e.memo.counts[:updated] = e.data.updated.size
    #   e.memo.counts[:filtered] = e.data.all.size
    #   e.data.all.each { |v|
    #     e.memo.details["#{v.city}-#{v.industry}"] ||= 0
    #     e.memo.details["#{v.city}-#{v.industry}"] += 1
    #   }
    # end
  end
  
  prepare
end
