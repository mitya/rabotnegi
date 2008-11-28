class Vacancy < ActiveRecord::Base
  property :title,         :string,   :null => false, :limit => 255
  property :description,   :text,     :null => false, :default => ''
  property :external_id,   :integer   
  property :industry,      :string,   :null => false, :limit => 255
  property :city,          :string,   :null => false, :limit => 255
  property :salary_min,    :integer   
  property :salary_max,    :integer   
  property :employer_id,   :integer   
  property :employer_name, :string,   :limit => 255
  extend Forwardable

  belongs_to :employer
  composed_of :salary, :mapping => {:salary_min => :min, :salary_max => :max}.to_a

  validates_presence_of :title, :description, :industry, :city

  def_delegator :salary, :text, :salary_text
  def_delegator :salary, :text=, :salary_text=

  def eql?(other)
    external_id? && other.external_id? ? external_id == other.external_id : super
  end

  def to_s
    title
  end
  
  def city_name
    City[city].name
  end

  def industry_name
    Industry[industry].name
  end
  
protected
  def after_initialize
    if new?
      self.city = 'msk' unless city.present?
    end
  end

  class << self
    def search(params)
      params.symbolize_keys!
      conditions = []
      conditions << {:city => params[:city]} if params[:city].present?
      conditions << {:industry => params[:industry]} if params[:industry].present?
      conditions << ["title LIKE :q or employer_name LIKE :q", {:q => "%#{params[:q]}%"}] if params[:q].present?
      conditions.inject(scoped({})) { |scope, condition| scope.scoped(:conditions => condition) }
    end    
  end
end
