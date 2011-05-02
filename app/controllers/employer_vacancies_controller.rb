# coding: utf-8

class EmployerVacanciesController < ApplicationController
  before_filter :employer_required
  before_filter :load_vacancy, :only => %w(show edit update destroy)

  def index
    @vacancies = current_employer.vacancies.all(:order => :title)
  end

  def show
  end

  def edit
    render 'vacancies/form'
  end

  def update
    if @vacancy.update_attributes(params[:vacancy])
      flash[:notice] = 'Вакансия сохранена'
      redirect_to employer_vacancies_path
    else
      render 'vacancies/form'
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
