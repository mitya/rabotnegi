class Vacancy < ActiveRecord::Base
	belongs_to :employer
	composed_of :salary, :mapping => [
		[:salary_min, :min],
		[:salary_max, :max]
	]
	
	def ==(other)
    id == other.id &&
		city == other.city &&
		industry == other.industry &&
		title == other.title &&
		description == other.description &&
		external_id == other.external_id &&
		employer_id == other.employer_id &&
		employer_name == other.employer_name &&
		salary == other.salary &&
		created_at == other.created_at &&
		updated_at == other.updated_at
	end
	alias eql? ==
	
	def link() id end
	
	def salary_text() salary.for_edit end
	def salary_text=(value) salary.for_edit = value end
end
