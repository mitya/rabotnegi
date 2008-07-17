class ResumesController < ApplicationController
  before_filter :check_id_cookie
	verify :only => [:edit, :update, :destroy], :session => :resume_id, :redirect_to => { :action => :login }
	ssl_required :login, :log_in
	
	def index
		if params[:city]
			@resumes = Resume.search(params)
		else
		  partial :search_form, :layout => true
		end		
	end

	def show
		@resume = Resume.find(params[:id])
    partial :show, :layout => true
	end
	
	def my
		redirect :login and return unless session[:resume_id]
		@resume = Resume.find(session[:resume_id])
	end
	
	def new
		@resume = Resume.new
    template :form
	end
	
	def edit
		@resume = my_resume
    template :form
	end
	
	def create
		@resume = Resume.new(params[:resume])
		@resume.save!
		flash[:notice] = "Резюме опубликовано"
		do_log_in
  rescue ActiveRecord::RecordInvalid
		template :form
	end
	
	def update
		@resume = my_resume
		@resume.update_attributes!(params[:resume])
		flash[:notice] = "Резюме сохранено"
		redirect :show
  rescue ActiveRecord::RecordInvalid
		template :form
	end
	
	def destroy
		@resume = my_resume
		@resume.destroy		
		flash[:notice] = 'Резюме удалено'
		log_out
	end
	
	
	def log_in
		begin
			fname, lname = params[:name].match(/(\w+)\s+(\w+)/).captures
		rescue NoMethodError
			error "Имя имеет неправильный формат", :login and return
		end
	
		@resume = Resume.find_by_name(lname, fname)
		if !@resume
			error "Резюме «#{params[:name]}» не найдено", :login
		elsif @resume.password != params[:password]
			error "Неправильный пароль", :login
		else
			do_log_in
		end
	end
	
	def log_out
    reset_session
    cookies.delete(:resume_id)
		redirect :login
	end

private
	def check_id_cookie
		return if session[:resume_id]
		if cookies[:resume_id] && Resume.exists?(cookies[:resume_id])
			session[:resume_id] = cookies[:resume_id].to_i
		end
	end
	
	def do_log_in
		session[:resume_id] = @resume.id
    if params[:remember_me] == 'on'
      cookies[:resume_id] = { :value => @resume.id.to_s, :expires => 14.days.from_now, :path => '/' }
    end
		redirect resume_url('my')
	end
	
	def error(message, action)
		flash[:error] = message
		template action
	end
	
	def my_resume
	  Resume.find(session[:resume_id])
	end
	
	def my_resume_id
	  session[:resume_id]
	end
end