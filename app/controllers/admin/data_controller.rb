class  Admin::DataController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  def index
    @klass = MongoReflector.reflect(params[:collection])
    @scope = @klass.reference.respond_to?(:query) ? @klass.reference.query(q: params[:q]) : @klass.reference
    @models = @scope.order_by(@klass.list_order).paginate(params[:page], @klass.list_page_size)
  end  
  
	def show
    @klass = MongoReflector.reflect(params[:collection])
  	selector = @klass.reference.singleton_methods(false).include?(:get) ? :get : :find
    @model = @klass.reference.send(selector, params[:id])
	end
end
