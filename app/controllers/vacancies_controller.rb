class VacanciesController < ApplicationController
  # caches_page :show, :if => -> c { c.request.xhr? }

  def index
    if params[:city]
      @vacancies = Vacancy.
        search(params.slice(:city, :industry, :q)).
        without(:description).
        order_by(decode_order_to_mongo(params[:sort].presence || "title")).
        paginate(params[:page], 50)
      current_user!.update_attributes(city: params[:city], industry: params[:industry]) unless bot?
    else
      params[:city] = current_user!.city      
      params[:industry] = current_user!.industry
    end
    
    respond_to do |wants|
      wants.html
      wants.json do
        render :json => JSON.generate(@vacancies.map { |v| v.attributes.slice(:title, :city, :industry, :external_id, :salary_min, :salary_max, :employer_name) })
      end
    end
  end

  def show
    @vacancy = Vacancy.get(params[:id])
    if @vacancy
      request.xhr?? render(partial: "details") : render
    else
      render "shared/404", status: params[:id] =~ /^\d{6}$/ ? 410 : 404
    end    
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
