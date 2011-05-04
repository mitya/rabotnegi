# coding: utf-8

class Vacancy
  include Mongoid::Document
  include Mongoid::Timestamps
    
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

  validates_presence_of :title, :industry, :city

  belongs_to :employer

  before_save do
    self.employer_id = employer.id if employer
    self.employer_name = employer.name if employer
  end

  def ==(other)
    Vacancy === other && external_id? ? self.external_id == other.external_id : super
  end

  def to_s
    title
  end
  
  def to_param
    parameterized_title = RussianInflector.parameterize(title)
    parameterized_title.present?? "#{id}-#{parameterized_title}" : id.to_s
  end
  
  def city_name
    City.get(city).name
  end

  def industry_name
    Industry.get(industry).name
  end
  
  def salary
    Salary.new(salary_min, salary_max)
  end
  
  def salary=(salary)
    self.salary_min = self.salary_max = nil
    self.salary_min = salary.min if salary
    self.salary_max = salary.max if salary
  end
  
  def salary_text
    salary.try(:text)
  end
  
  def salary_text=(value)
    self.salary = Salary.parse(value)
  end
  
  def self.search(params)
    params = params.symbolize_keys
    params.assert_valid_keys(:city, :industry, :q)
    query = Regexp.new(params[:q] || "", true)

    scope = self
    scope = scope.where(city: params[:city]) if params[:city].present?
    scope = scope.where(industry: params[:industry]) if params[:industry].present?
    scope = scope.any_of({title: query}, {employer_name: query}, {description: query}) if params[:q].present?
    scope
  end    
  
  def self.cleanup
    where(:updated_at.lt => 2.weeks.ago).destroy
  end
  
  def self.get(id)
    id ||= ""
    id = id.gsub(/\-.*/, '') if String === id
    where(_id: id).first
  end
end
