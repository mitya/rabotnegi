class ResumesController < ApplicationController
	# before_filter :check_id_cookie
	verify :session => :resume_id, :redirect_to => { :action => :login }, :only => [:edit, :update, :destroy]
	ssl_required :login, :log_in
	
	def index
		if params[:city]
		  params[:keywords] = nil if params[:keywords].blank?
			@resumes = Resume.search(params)
			render :action => :list	
		else
		  @page_title = 'Поиск резюме'
      render_multiview :search_form		  
		end		
	end

	def show
		if params[:id] == 'my'
			if session[:resume_id]
				@resume = Resume.find(session[:resume_id])
				render :action => 'show_my' 
			else	
				redirect_to :action => 'login'
			end
		else
			@resume = Resume.find(params[:id])
			@page_title = @resume.name
      render_multiview :show
		end
	end
	
	def new
		@resume = Resume.new
		@page_title = 'Публикация резюме'
    render_multiview :form, :action => resumes_path, :method => :post, :action_label => 'Опубликовать'
	end
	
	def edit
		@resume = Resume.find session[:resume_id]
		@page_title = 'Редактирование резюме'
    render_multiview :form, :action => resume_path(:my), :method => :put, :action_label => 'Сохранить'
	end
	
	def create
		@resume = Resume.new params[:resume]
		if @resume.save
			flash[:notice] = "Резюме опубликовано"
			do_log_in
		else
			render :action => 'new'
		end			
	end
	
	def update
		@resume = Resume.find(session[:resume_id])
		if @resume.update_attributes params[:resume]
			flash[:notice] = "Резюме сохранено"
			redirect_to :action => :show
		else
			render :action => 'edit'
		end
	end
	
	def destroy
		@resume = Resume.find(session[:resume_id])
		@resume.destroy
		
		flash[:notice] = 'Резюме удалено'		
		log_out
	end
	
	
	def log_in
		begin
			fname, lname = params[:name].match(/(\w+)\s+(\w+)/).captures
		rescue NoMethodError
			error "Имя имеет неправильный формат", 'login'; return
		end
	
		@resume = Resume.find_by_name lname, fname
		if !@resume
			error "Резюме «#{fname} #{lname}» не найдено", 'login'
		elsif @resume.password != params[:password]
			error "Неправильный пароль", 'login'
		else
			do_log_in
		end
	end
	
	def log_out
		session[:resume_id] = nil
		# cookies.delete(:resume_id) if cookies[:resume_id]
		redirect_to :action => 'login'
	end
	

private
	def check_id_cookie
		return if session[:resume_id]
		if cookies[:resume_id] && Resume.exists?(cookies[:resume_id])
			session[:resume_id] = cookies[:resume_id].to_i end
	end
	
	def do_log_in
		session[:resume_id] = @resume.id
		# if params[:remember_me] = 'on'
		# 	cookies[:resume_id] = {:value=>@resume.id.to_s, :expires=>14.days.from_now, :path=>'/'} end
		redirect_to resume_url('my')
	end
	
	def error message, action
		flash[:error] = message
		render :action => action
	end
end
