class Resume < ActiveRecord::Base	
  property :fname,        :string
  property :lname,        :string
  property :password,     :string
  property :city,         :string
  property :industry,     :string
  property :job_title,    :string
  property :min_salary,   :integer, :default => 0
  property :view_count,   :integer
  property :job_reqs,     :text
  property :about_me,     :text
  property :contact_info, :text
  
	validates_presence_of :fname, :lname, :city, :job_title, :industry
	validates_presence_of :contact_info, :message => "Укажите телефон или электронную почту в контактной информации."
	validates_numericality_of :min_salary, :message => "Укажите зарплату — число в рублях."
	
	def name
	  [fname, lname].compact.join(' ')
	end
		
	def to_s
		"#{name} — #{job_title} (от #{min_salary} р.)"
	end
		
	class << self
  	def search(params)
  	  results = scoped({})
  	  results = results.where(:city => params[:city]) if params[:city].present?
  	  results = results.where(:industry => params[:industry]) if params[:industry].present?
  	  results = results.where("job_title LIKE ?", "%#{params[:keywords]}%") if params[:keywords].present?

  		if params[:salary].present?
  			direction, value = params[:salary].match(/(-?)(\d+)/).captures
  			op = direction == '-' ? :<= : :>=
  			results = results.where("min_salary #{op} ?", value)
  		end      

      results
  	end

  	def authenticate(name, password)
  	  name =~ /(\w+)\s+(\w+)/ || raise(ArgumentError, "Имя имеет неправильный формат")
  	  first, last = $1, $2
  	  resume = find_by_lname_and_fname(lname, fname) || raise(ArgumentError, "Резюме «#{name}» не найдено")
      resume.password == password || raise(ArgumentError, "Неправильный пароль")
      resume
  	end
	end
end