# coding: utf-8

class VacanciesController < ApplicationController
  caches_page :show, :if => -> c { c.request.xhr? }

  def index
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      without(:description).
      order_by(decode_order_for_mongo(params[:sort].presence || "title")).
      paginate(page: params[:page], per_page: 50) if params[:city]
  end

  def show
    @vacancy = Vacancy.find(params[:id])
    request.xhr?? render(partial: "vacancy", object: @vacancy) : render
  end
  
  def new
    @vacancy = Vacancy.new
    render :form
  end

  def create
    @vacancy = Vacancy.new(params[:vacancy])
    if @vacancy.save
      redirect_to '/', notice: 'Вакансия опубликована'
    else
      render :form, status: 422
    end
  end
  
end
