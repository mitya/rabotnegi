class EmployersController < ApplicationController
  ssl_required :new, :create
  
	def index
		redirect_to my_vacancies_url if session[:employer_id]
	end
	
	def new
		@employer = Employer.new
	end

	def create
		@employer = Employer.new params[:employer]
		if @employer.save_with_captcha
			flash[:notice] = "Работодатель «#{@employer.name}» зарегистрирован"
			remember_and_redirect
		else
			render :action => 'new'
		end
	end
	
	def log_in
		@employer = Employer.authenticate(params[:login], params[:password])
		if @employer
			remember_and_redirect
		else
			flash[:error] = 'Неправильная комбинация логина и пароля'
			render :action => 'index'
		end
	end

	def log_out
		session[:employer_id] = nil
		flash[:notice] = 'Вы вышли из системы'
		redirect_to employers_path
	end
		
private
	def remember_and_redirect
		session[:employer_id] = @employer.id
		redirect_to my_vacancies_path
	end
end