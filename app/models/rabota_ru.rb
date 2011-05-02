# coding: utf-8

module RabotaRu
  mattr_accessor :logger
  self.logger = Logger.new("#{Rails.root}/log/loader_#{Rails.env}.log", Logger::DEBUG)
  def logger.format_message(severity, timestamp, progname, msg)
    "#{timestamp.xmlschema} #{msg}\n"
  end
  
  def self.load
    RabotaRu::VacancyLoader.new.load
  end

  class VacancyLoading
    include Mongoid::Document
    include Mongoid::Timestamps

    field :state, type: String
    field :details, type: Hash
    field :new_count, type: Integer
    field :updated_count, type: Integer
    field :started_at, type: Time
    field :finished_at, type: Time
  end
end
