class Vacancy < ActiveRecord::Base
  extend Forwardable
  
  property :title, :string
  property :description, :text
  property :external_id, :integer
  property :industry, :string
  property :city, :string
  property :salary_min, :integer
  property :salary_max, :integer
  property :employer_name, :string
    
  belongs_to :employer
  composed_of :salary, :mapping => {:salary_min => :min, :salary_max => :max}.to_a

  validates_presence_of :title, :description, :industry, :city
  
  def_delegator :salary, :for_edit, :salary_text
  def_delegator :salary, :for_edit=, :salary_text=
  
  def eql?(other)
    attributes == other.attributes
  end
  
  def to_s
    title
  end
  
protected
  def after_initialize
    if new?
      self.city = 'msk' unless city.present?
    end
  end
  
  class << self
    def search(params)
      results = scoped({})
  	  results = results.where(:city => params[:city]) if params[:city].present?
  	  results = results.where(:industry => params[:industry]) if params[:industry].present?
  	  results = results.where("title LIKE :q or employer_name LIKE :q", :q => "%#{params[:q]}%") if params[:q].present?
      results
    end    
  end
end