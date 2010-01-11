class Resume
  include DataMapper::Resource
  
  property :id,           Serial
  property :fname,        String,   :required => true, :length => 30
  property :lname,        String,   :required => true, :length => 30
  property :password,     String,   :length => 30
  property :city,         String,   :required => true, :length => 255
  property :job_title,    String,   :required => true, :length => 100
  property :industry,     String,   :required => true, :length => 255
  property :min_salary,   Integer,  :required => true
  property :view_count,   Integer,  :required => true, :default => 0
  property :job_reqs,     Text, :lazy => [:show]
  property :about_me,     Text, :lazy => [:show]
  property :contact_info, Text, :required => true, :lazy => [:show], :messages => {:presence => "укажите телефон или электронную почту"}
  property :created_at, DateTime
  property :updated_at, DateTime
  
	validates_is_number :min_salary
	
	def name
	  "#{fname} #{lname}".squish
	end
		
	def to_s
		"#{name} — #{job_title} (от #{min_salary} р.)"
	end
		
	def self.search(params)
	  params = params.symbolize_keys
	  params.assert_valid_keys(:city, :industry, :salary, :keywords)
	  
	  conditions = []
    conditions << {:city => params[:city]} if params[:city].present?
	  conditions << {:industry => params[:industry]} if params[:industry].present?
	  conditions << {:conditions => ["job_title LIKE ?", "%#{params[:keywords]}%"]} if params[:keywords].present?	  
		if params[:salary].present?
			direction, value = params[:salary].match(/(-?)(\d+)/).captures
			op = direction == '-' ? :<= : :>=
			conditions << ["min_salary #{op} ?", value]
		end
		
		conditions.inject(all) { |results, c| results.all(c) }
	end

  def self.authenticate(name, password)
	  name =~ /(\w+)\s+(\w+)/ || raise(ArgumentError, "Имя имеет неправильный формат")
	  first, last = $1, $2
	  resume = first(:lname => last, :fname => first) || raise(ArgumentError, "Резюме «#{name}» не найдено")
    resume.password == password || raise(ArgumentError, "Неправильный пароль")
    resume
	end
end
