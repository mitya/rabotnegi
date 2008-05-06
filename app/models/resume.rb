class Resume < ActiveRecord::Base	
	validates_presence_of :fname, :message => 'Укажите имя.'
	validates_presence_of :lname, :message => 'Укажите фамилию.'
	validates_presence_of :city
	validates_presence_of :job_title
	validates_presence_of :industry
	validates_presence_of :min_salary
	validates_presence_of :contact_info, :message => "Укажите телефон или электронную почту в контактной информации."
	validates_numericality_of :min_salary, :message => "Укажите зарплату — число в рублях."
	
	def self.search params
		params[:keywords_esc] = "%#{params[:keywords]}%" if params[:keywords]

		filter = 'city = :city'
		filter << ' and industry = :industry' if params[:industry]
		filter << ' and job_title like :keywords_esc' if params[:keywords_esc]
		if params[:salary]
			direction, value = params[:salary].match(/(-?)(\d+)/).captures
			search_down = direction == '-'
			filter << " and min_salary #{search_down ? '<=' : '>='} #{value} " end
		
		return find(:all,
				:conditions => [filter, params],
				:order => 'min_salary',
				:select => 'id, job_title, min_salary')
	end
	
	def self.find_by_name(lname, fname)
		return find(:first, :conditions=>['lname = ? and fname = ?', lname, fname]) end
	
	def name
		!lname.blank? ? "#{fname} #{lname}" : fname end
		
	def summary
		"#{name} — #{job_title} (#{salary_text})" end
		
	def salary_text
		"от #{min_salary} р." end
end

