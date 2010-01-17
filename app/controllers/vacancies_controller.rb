class VacanciesController < ApplicationController
  caches_page :show, :if => proc { |c| c.request.format.ajax? }

  def index
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      all(:order => decode_order_to_expr(params[:sort]) || :title).
      paginate(:page => params[:page], :per_page => 50) if params[:city]
  end

  def show
    @vacancy = Vacancy.get(params[:id])
    respond_to do |f|
      f.html
      f.ajax { render :partial => "vacancy", :object => @vacancy }
    end
  end
end
