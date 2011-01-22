class Vacancy < ActiveRecord::Base
  # property :id,            :Serial
  # property :title,         String, :required => true, :length => 255
  # property :description,   Text, :required => true
  # property :external_id,   Integer   
  # property :industry,      String, :required => true, :length => 255
  # property :city,          String, :required => true, :length => 255
  # property :salary_min,    Integer   
  # property :salary_max,    Integer   
  # property :employer_id,   Integer   
  # property :employer_name, String, :length => 255
  # property :created_at, DateTime
  # property :updated_at, DateTime

  validates_presence_of :title, :description, :industry, :city

  belongs_to :employer

  delegate :text, :text=, :to => :salary, :prefix => true

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
  
  def salary
    @salary ||= Salary.new(salary_min, salary_max)
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

  def before_save
    if employer
      self.employer_id = employer.id
      self.employer_name = employer.name
    end
  end

  def self.search(params)
    params = params.symbolize_keys
    params.assert_valid_keys(:city, :industry, :q)
    
    conditions = []
    conditions << {:city => params[:city]} if params[:city].present?
    conditions << {:industry => params[:industry]} if params[:industry].present?
    conditions << ["title LIKE :q OR employer_name LIKE :q", {:q => "%#{params[:q]}%"}] if params[:q].present?
    
    conditions.inject(self) { |results, condition| results.where(condition) }
  end    
  
  def self.cleanup
    olds = where(["updated_at < ?", 2.weeks.ago])
    olds.destroy!
  end
end
