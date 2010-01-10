class Employer
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true, :length => 255
  property :login,      String, :required => true, :length => 255
  property :password,   String, :required => true, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_is_unique :login
  validates_is_confirmed :password

  has n, :vacancies

  # apply_simple_captcha :message => "набранные буквы не совпадают"

  attr_accessor :password_confirmation
  
  def to_s
    name
  end
  
private
  # def initialize_vacancy(vacancy)
  #   vacancy.employer_id = id
  #   vacancy.employer_name = name    
  # end
  
  def self.authenticate(login, password)
    first(:login => login, :password => password) || raise(ArgumentError)
  end
end
