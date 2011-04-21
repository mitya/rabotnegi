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
end
