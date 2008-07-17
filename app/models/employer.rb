class Employer < ActiveRecord::Base
	has_many :vacancies

	attr_accessor :password_confirmation

	validates_presence_of :name, :login, :password, :password_confirmation
	validates_uniqueness_of :login
	validates_confirmation_of :password

	apply_simple_captcha
	
	def self.authenticate(login, password)
		find_by_login_and_password(login, password)
	end
end
