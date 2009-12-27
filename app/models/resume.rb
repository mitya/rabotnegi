class Resume < ActiveRecord::Base	
  property :fname,        :string,   :null => false, :limit => 30
  property :lname,        :string,   :null => false, :limit => 30
  property :password,     :string,   :limit => 30
  property :city,         :string,   :null => false, :limit => 255
  property :job_title,    :string,   :null => false, :limit => 100
  property :industry,     :string,   :null => false, :limit => 255
  property :min_salary,   :integer,  :null => false
  property :view_count,   :integer,  :null => false, :default => 0
  property :job_reqs,     :text      
  property :about_me,     :text      
  property :contact_info, :text      
  
	validates_presence_of :fname, :lname, :city, :job_title, :industry, :min_salary
	validates_presence_of :contact_info, :message => "укажите телефон или электронную почту"
	validates_numericality_of :min_salary, :allow_blank => true
	
	def name
	  "#{fname} #{lname}".squish
	end
		
	def to_s
		"#{name} — #{job_title} (от #{min_salary} р.)"
	end
		
	def self.search(params)
	  conditions = []
	  conditions << {:city => params[:city]} if params[:city].present?
	  conditions << {:industry => params[:industry]} if params[:industry].present?
	  conditions << ["job_title LIKE ?", "%#{params[:keywords]}%"] if params[:keywords].present?	  
		if params[:salary].present?
			direction, value = params[:salary].match(/(-?)(\d+)/).captures
			op = direction == '-' ? :<= : :>=
			conditions << ["min_salary #{op} ?", value]
		end
		
    scoped :conditions => merge_conditions(*conditions)
	end

  def self.authenticate(name, password)
	  name =~ /(\w+)\s+(\w+)/ || raise(ArgumentError, "Имя имеет неправильный формат")
	  first, last = $1, $2
	  resume = find_by_lname_and_fname(last, first) || raise(ArgumentError, "Резюме «#{name}» не найдено")
    resume.password == password || raise(ArgumentError, "Неправильный пароль")
    resume
	end
end
