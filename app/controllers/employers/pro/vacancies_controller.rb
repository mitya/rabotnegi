class Employers::Pro::VacanciesController < ApplicationController
  before_filter :employer_required
  before_filter :load_vacancy, :except => [:index, :new, :create]

  def index
    @vacancies = current_employer.vacancies.all(:order => 'title', :select => 'id, title, external_id, salary_min, salary_max, employer_name')
    template 'employers/vacancies/index'
  end

  def show
    template 'employers/vacancies/show'
  end

  def new
    @vacancy = Vacancy.new
    template 'employers/vacancies/form'
  end

  def edit
    template 'employers/vacancies/form'
  end
  
  def create
    @vacancy = current_employer.vacancies.new(params[:vacancy])
    @vacancy.save!
    flash[:notice] = 'Вакансия опубликована'
    redirect :index
  rescue RecordInvalid
    template 'employers/vacancies/form'
  end
  
  def update
    @vacancy.update_attributes!(params[:vacancy])
    flash[:notice] = 'Вакансия сохранена'
    redirect :index
  rescue RecordInvalid
    template 'employers/vacancies/form'
  end

  def destroy
    @vacancy.destroy
    flash[:notice] = "Вакансия «#{@vacancy.title}» удалена"
    redirect :index
  end

private
  def load_vacancy
    @vacancy ||= current_employer.vacancies.find(params[:id])
  end
end