# coding: utf-8

class VacancyMongo
  include Mongoid::Document
  include Mongoid::Timestamps
    
  store_in :vacancies
    
  field :title
  field :description
  field :external_id, type: Integer   
  field :industry
  field :city
  field :salary_min, type: Integer
  field :salary_max, type: Integer   
  field :employer_id, type:Integer   
  field :employer_name
  
  index :city
  index :industry
  index [[:city, 1], [:industry, 1]]
  index [[:city, 1], [:title, 1]]

  validates_presence_of :title, :description, :industry, :city

  # belongs_to :employer
  # composed_of :salary, :mapping => [ %w(salary_min min), %w(salary_max max) ]
  # 
  # delegate :text, :to => :salary, :prefix => true

  def ==(other)
    self.external_id? && other.external_id? ? 
      self.external_id == other.external_id : super
  end

  def to_s
    title
  end
  
  def to_param
    "#{id}"
  end
  
  def city_name
    City.get(city).name
  end

  def industry_name
    Industry.get(industry).name
  end
  
  def initialize(attributes = {})
    super
    self.city ||= 'msk'
  end
  
  # def salary_text=(value)
  #   self.salary = Salary.parse(value)
  # end
  # 
  # before_save do
  #   if employer
  #     self.employer_id = employer.id
  #     self.employer_name = employer.name
  #   end
  # end
  # 
  # def self.search(params)
  #   params = params.symbolize_keys
  #   params.assert_valid_keys(:city, :industry, :q)
  #   
  #   conditions = []
  #   conditions << {:city => params[:city]} if params[:city].present?
  #   conditions << {:industry => params[:industry]} if params[:industry].present?
  #   conditions << ["title LIKE :q OR employer_name LIKE :q", {:q => "%#{params[:q]}%"}] if params[:q].present?
  #   
  #   conditions.inject(self) { |results, condition| results.where(condition) }
  # end    
  # 
  # def self.cleanup
  #   olds = where(["updated_at < ?", 2.weeks.ago])
  #   olds.destroy!
  # end
end
