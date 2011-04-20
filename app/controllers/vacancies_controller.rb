class VacanciesController < ApplicationController
  caches_page :show, :if => -> c { c.request.format.ajax? }

  N = 20
  S = "city"

  def index
    GC.start
    GC.disable

    benchmark "--- Mongo" do
      VacancyMongo.db.collection("vacancies").find({city: "msk"}, sort: [[S, Mongo::ASCENDING]], limit: N, :fields => {description: 0}).to_a
    end
    
    benchmark "--- MySQL" do
      Vacancy.connection.select_all("SELECT id, title, external_id, salary_min, salary_max, employer_name FROM `vacancies` WHERE `vacancies`.`city` = 'msk' ORDER BY #{S} asc LIMIT #{N} OFFSET 0")
    end

    benchmark "--- Mongoid" do
      VacancyMongo.where(city: "msk").asc(S).without(:description).limit(N).to_a
    end        

    benchmark "--- ActiveRecord" do      
      Vacancy.where(:city => "msk").select("id, title, external_id, salary_min, salary_max, employer_name").order(S).limit(N).to_a
    end

    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      scoped(order: decode_order_to_expr(params[:sort]) || :title, select: 'id, title, external_id, salary_min, salary_max, employer_name').
      paginate(page: params[:page], per_page: N) if params[:city]
    
  ensure
    GC.enable
  end

  def show
    @vacancy = Vacancy.get(params[:id])
    respond_to do |f|
      f.html
      f.ajax { render partial: "vacancy", object: @vacancy }
    end
  end
end
