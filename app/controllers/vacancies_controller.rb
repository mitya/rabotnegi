class VacanciesController < ApplicationController
  before_filter :load_vacancy, :only => [:show, :edit, :update, :destroy, :description]
  before_filter :authenticate, :only => [:my, :edit, :update, :delete]
  before_filter :authorize, :only => [:edit, :update, :delete]

  def index
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      scoped(:select => 'id, title, external_id, salary_min, salary_max, employer_name').
      paginate(:page => params[:p], :per_page => 50, :order_by => params[:s] || 'salary_min') if params[:city]    
  end

  def description
    partial :description
  end
  
  def show
  end

  def new
    @vacancy = Vacancy.new
    template :form
  end

  def edit
    template :form
  end
  
  def create
    vacancies = session[:employer_id] ? Employer.find(session[:employer_id]).vacancies : Vacancy
    @vacancy = vacancies.new(params[:vacancy])
    @vacancy.save!
    flash[:notice] = 'Вакансия опубликована'
    redirect_home
  end
  
  def update
    @vacancy.update_attributes!(params[:vacancy])
    flash[:notice] = 'Вакансия сохранена'
    redirect_home
  end

  def destroy
    @vacancy.destroy
    flash[:notice] = "Вакансия «#{@vacancy.title}» удалена"
    redirect_home 
  end

  def my
    @employer = Employer.find(session[:employer_id])
    @vacancies = @employer.vacancies.all(:order => 'title', :select => 'id, title, external_id, salary_min, salary_max, employer_name')
  end 

private
  def load_vacancy
    @vacancy = Vacancy.find(params[:id])
  end
  
  def load_employer
    @employer = Employer.find(session[:employer_id]) unless defined? @employer
    @employer
  end 
  
  def authenticate
    redirect_home if not session[:employer_id]
  end

  def authorize
    redirect_home if not @employer.vacancies.find(params[:id])
  end 

  def redirect_home
    redirect session[:employer_id] ? my_vacancies_url : employers_url
  end
end