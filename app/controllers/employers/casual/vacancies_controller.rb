class Employers::Casual::VacanciesController < ApplicationController
  def new
    @vacancy = Vacancy.new
    template 'employers/vacancies/form'
  end

  def create
    @vacancy = Vacancy.new(params[:vacancy])
    @vacancy.save!
    flash[:notice] = 'Вакансия опубликована'
    redirect employers_path
  rescue RecordInvalid
    template 'employers/vacancies/form'
  end
end