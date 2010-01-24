class Employers::VacanciesController < ApplicationController
  before_filter :employer_required, :except => %w(new create)
  before_filter :load_vacancy, :only => %w(show edit update destroy)

  def new
    @vacancy = Vacancy.new
    render 'employers/vacancy_form'
  end

  def create
    @vacancy = if current_employer
      current_employer.vacancies.build(params[:vacancy])
    else
      Vacancy.new(params[:vacancy])
    end
    
    if @vacancy.save
      flash[:notice] = 'Вакансия опубликована'
      redirect_to employer_path
    else
      render 'employers/vacancy_form', :status => 422
    end
  end

  def index
    @vacancies = current_employer.vacancies.all(:order => :title)
    render 'employers/vacancies'
  end

  def show
    render 'employers/vacancy'
  end

  def edit
    render 'employers/vacancy_form'
  end

  def update
    if @vacancy.update(params[:vacancy])
      flash[:notice] = 'Вакансия сохранена'
      redirect_to employer_vacancies_path
    else
      render 'employers/vacancy_form'
    end
  end

  def destroy
    @vacancy.destroy
    flash[:notice] = "Вакансия «#{@vacancy.title}» удалена"
    redirect_to employer_vacancies_path
  end

private
  def load_vacancy
    @vacancy ||= current_employer.vacancies.get(params[:id])
  end
end
