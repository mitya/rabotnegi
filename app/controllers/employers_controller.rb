class EmployersController < ApplicationController
	def index
		redirect employer_vacancies_path if current_employer?
	end
	
	def new
		@employer = Employer.new
	end

	def create
		@employer = Employer.new(params[:employer])
		@employer.save_with_captcha!
		flash[:notice] = "Работодатель «#{@employer}» зарегистрирован"
		session[:employer_id] = @employer.id
		redirect employer_vacancies_path
	rescue RecordInvalid
		template :new, :status => 422
	end
	
	def log_in
		@employer = Employer.authenticate(params[:login], params[:password])
		session[:employer_id] = @employer.id
		redirect employer_vacancies_path
	rescue ArgumentError
		flash[:error] = 'Неправильная комбинация логина и пароля'
		template :index	  
	end

	def log_out
		reset_session
		flash[:notice] = 'Вы вышли из системы'
		redirect :index
	end
end
