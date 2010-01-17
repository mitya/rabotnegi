class Vacancy
  include DataMapper::Resource

  property :id,            Serial
  property :title,         String, :required => true, :length => 255
  property :description,   Text, :required => true
  property :external_id,   Integer   
  property :industry,      String, :required => true, :length => 255
  property :city,          String, :required => true, :length => 255
  property :salary_min,    Integer   
  property :salary_max,    Integer   
  property :employer_id,   Integer   
  property :employer_name, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :employer

  delegate :text, :text=, :to => :salary, :prefix => true

  def ==(other)
    self.external_id? && other.external_id? ? 
      self.external_id == other.external_id : 
      super
  end

  def to_s
    title
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

  before :save do
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
    conditions << {:conditions => ["title LIKE ? OR employer_name LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%"]} if params[:q].present?

    conditions.inject(all) { |results, c| results.all(c) }
  end    
  
  def self.cleanup
    olds = all(:updated_at.lt => 2.weeks.ago)
    olds.destroy!
  end
end
