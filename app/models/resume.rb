class Resume < ActiveRecord::Base	
	validates_presence_of :fname, :message => 'Укажите имя.'
	validates_presence_of :lname, :message => 'Укажите фамилию.'
	validates_presence_of :city
	validates_presence_of :job_title
	validates_presence_of :industry
	validates_presence_of :min_salary
	validates_presence_of :contact_info, :message => "Укажите телефон или электронную почту в контактной информации."
	validates_numericality_of :min_salary, :message => "Укажите зарплату — число в рублях."
	
	def name
		!lname.blank? ? "#{fname} #{lname}" : fname
	end
		
	def summary
		"#{name} — #{job_title} (#{salary_text})"
	end
		
	def salary_text
		"от #{min_salary} р."
	end
	
	class << self
  	def search(params)
  	  results = order_by(:min_salary).select(:id, :job_title, :min_salary)

  	  results = results.where(:city => params[:city]) unless params[:city].blank?
  	  results = results.where(:industry => params[:industry]) unless params[:industry].blank?
  	  results = results.where(["job_title LIKE ?", "%#{params[:keywords]}%"]) unless params[:keywords].blank?

  		if params[:salary]
  			direction, value = params[:salary].match(/(-?)(\d+)/).captures
  			op = direction == '-' ? :<= : :>=
  			results = results.where(["min_salary #{op} ?", value])
  		end
      
      results
  	end	  

  	def find_by_name(lname, fname)
  	  find_by_lname_and_fname(lname, fname)
  	end  	
	end
end