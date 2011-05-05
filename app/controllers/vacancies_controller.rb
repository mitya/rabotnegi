# coding: utf-8

class VacanciesController < ApplicationController
  caches_page :show, :if => -> c { c.request.xhr? }

  def index
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      without(:description).
      order_by(decode_order_for_mongo(params[:sort].presence || "title")).
      paginate(page: params[:page], per_page: 50) if params[:city]

    respond_to do |wants|
      wants.html
      wants.json do
        render :json => JSON.generate(@vacancies.map { |v| v.attributes.slice(:title, :city, :industry, :external_id, :salary_min, :salary_max, :employer_name) })
      end
    end
  end

  def show
    @vacancy = Vacancy.get(params[:id])
    request.xhr?? render(partial: "details") : render
  end

  def new
    @vacancy = Vacancy.new
    render :form
  end

  def create
    @vacancy = Vacancy.new(params[:vacancy])
    if @vacancy.save
      redirect_to vacancy_path(@vacancy), notice: 'Вакансия опубликована'
    else
      render :form, status: 422
    end
  end  
end
