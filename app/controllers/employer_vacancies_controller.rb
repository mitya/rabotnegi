class EmployerVacanciesController < ApplicationController
  before_filter :employer_required, :except => %w(new create)
  before_filter :load_vacancy, :except => [:index, :new, :create]

  def new
    @vacancy = Vacancy.new
    template 'employers/vacancy_form'
  end

  def create
    @vacancy = if current_employer
      current_employer.vacancies.build(params[:vacancy])
    else
      Vacancy.new(params[:vacancy])
    end
    @vacancy.save!
    flash[:notice] = 'Вакансия опубликована'
    redirect employers_path
  rescue RecordInvalid
    template 'employers/vacancy_form'
  end

  def index
    @vacancies = current_employer.vacancies.all(:order => 'title', :select => 'id, title, external_id, salary_min, salary_max, employer_name')
    template 'employers/vacancies'
  end

  def show
    template 'employers/vacancy'
  end

  def edit
    template 'employers/vacancy_form'
  end

  def update
    @vacancy.update_attributes!(params[:vacancy])
    flash[:notice] = 'Вакансия сохранена'
    redirect :index
  rescue RecordInvalid
    template 'employers/vacancy_form'
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
