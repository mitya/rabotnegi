#   match 'hello', :to => HelloController.action(:index)
class MetalController < ActionController::Metal
  # include ActionController::Rendering
  # append_view_path "#{Rails.root}/app/views"
  # 
  # def index
  #   render "hello/index"
  # end
  
  def show_vacancy
    @vacancy = Vacancy.get(params[:id])

    self.content_type = "application/json"
    self.response_body = JSON.generate(@vacancy.attributes)
  end
  
  def index_vacancies
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      without(:description).
      order_by(decode_order_for_mongo(params[:sort].presence || "title")).
      paginate(page: params[:page], per_page: 50) if params[:city]

    Rails.logger.debug request.format

    data = @vacancies.map { |v| v.attributes.slice(:title, :city, :industry, :external_id, :salary_min, :salary_max, :employer_name) }
    self.content_type = "application/json"
    self.response_body = JSON.generate(data)
  end

private

  def decode_order(param = params[OrderParam])
    param.present??
      param.starts_with?('-') ? 
        [param.from(1), true] : 
        [param, false] :
      [nil, false]
  end  

  def decode_order_for_mongo(param = params[OrderParam])
    field, reverse = decode_order(param)
    [[field, reverse ? Mongo::DESCENDING : Mongo::ASCENDING]]
  end
end
