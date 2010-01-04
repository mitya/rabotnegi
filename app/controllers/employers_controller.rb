class EmployersController < ApplicationController
	def new
		@employer = Employer.new
	end

	def create
		@employer = Employer.new(params[:employer])
		@employer.save_with_captcha!
		flash[:notice] = "Работодатель «#{@employer}» зарегистрирован"
		session[:employer_id] = @employer.id
		redirect_to employer_vacancies_path
	rescue RecordInvalid
		render :new, :status => 422
	end

	def welcome
		redirect_to employer_vacancies_path and return if current_employer?
		render :index
	end
	
	def login
		@employer = Employer.authenticate(params[:login], params[:password])
		session[:employer_id] = @employer.id
		redirect_to employer_vacancies_path
	rescue ArgumentError
		flash[:error] = 'Неправильная комбинация логина и пароля'
		render :index
	end

	def logout
		reset_session
		flash[:notice] = 'Вы вышли из системы'
		redirect_to employer_vacancies_path
	end
end
