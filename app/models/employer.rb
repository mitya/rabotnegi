class Employer < ActiveRecord::Base
  property :name,       :string,   :null => false, :limit => 255
  property :login,      :string,   :limit => 255
  property :password,   :string,   :limit => 255

  attr_accessor :password_confirmation
  
  has_many :vacancies, :before_add => :initialize_vacancy

  validates_presence_of :name, :login, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password

  apply_simple_captcha :message => "набранные буквы не совпадают"
  
  def to_s
    name
  end
  
private
  def initialize_vacancy(vacancy)
    vacancy.employer_id = id
		vacancy.employer_name = name		
  end
  
  class << self
    def authenticate(login, password)
      find_by_login_and_password(login, password) || raise(ArgumentError)
    end   
  end
end
