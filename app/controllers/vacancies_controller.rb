class VacanciesController < ApplicationController
  caches_page :show, :if => proc { |c| c.request.format.ajax? }

  def index
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      scoped(:select => 'id, title, external_id, salary_min, salary_max, employer_name').
      paginate(:page => params[:p], :per_page => 50, :order_by => params[:s] || 'salary_min') if params[:city]
  end

  def show
    @vacancy = Vacancy.find(params[:id])
    respond_to do |f|
      f.html
      f.ajax { partial @vacancy }
    end
  end
end