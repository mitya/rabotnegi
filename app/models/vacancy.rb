class Vacancy < ActiveRecord::Base
	belongs_to :employer
	composed_of :salary, :mapping => [
		[:salary_min, :min],
		[:salary_max, :max]
	]
	
	def ==(other)
		[:id, :city, :industry, :title, :description, :external_id, :employer_id,
		  :employer_name, :salary, :created_at, :updated_at].all? { |attr| self.send(attr) == other.send(attr) }
	end
	alias eql? ==
	
	def salary_text 
	  salary.for_edit
	end
	
	def salary_text=(value)
	  salary.for_edit = value
	end
end