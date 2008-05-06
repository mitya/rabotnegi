class Employer < ActiveRecord::Base
	apply_simple_captcha
	has_many :vacancies
	attr_accessor :password_confirmation

	validates_presence_of :name, :login, :password, :password_confirmation
	validates_uniqueness_of :login
	validates_confirmation_of :password
	
	def self.authenticate login, password
		return find(:first, :conditions=>['login = ? and password = ?', login, password])
	end
end
