# coding: utf-8

class EmployersController < ApplicationController
	def new
		@employer = Employer.new
	end

	def create
	  @employer = Employer.new(params[:employer])

    if not simple_captcha_valid?(keep: true)
      @employer.errors.add(:captcha, "not valid")
      render :new, status: 422 and return
    end
    
		if @employer.save		
  		flash[:notice] = "Работодатель «#{@employer}» зарегистрирован"
  		session[:employer_id] = @employer.id
  		simple_captcha_passed!
  		redirect_to employer_vacancies_path
	  else
		  render :new, status: 422
		end
	end

	def welcome
		redirect_to employer_vacancies_path and return if current_employer
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
