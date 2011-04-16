class Employer < ActiveRecord::Base
  # property :id,         :Serial
  # property :name,       String, :required => true, :length => 255
  # property :login,      String, :required => true, :length => 255
  # property :password,   String, :required => true, :length => 255
  # property :created_at, DateTime
  # property :updated_at, DateTime

  validates_presence_of :name, :login, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password

  has_many :vacancies, :before_add => :initialize_vacancy

  attr_accessor :password_confirmation
  
  def to_s
    name
  end
  
private
  def initialize_vacancy(vacancy)
    vacancy.employer_id = id
    vacancy.employer_name = name    
  end

  def self.authenticate(login, password)
    where(:login => login, :password => password).first || raise(ArgumentError)
  end
end
