class  Admin::DataController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  def index
    @metadata = MongoReflector.reflect(params[:collection])
    @klass = @metadata.reference
    @scope = @klass.respond_to?(:query) ? @klass.query(q: params[:q]) : @klass
    @models = @scope.paginate(params[:page], 30)
  end  
  
	def show
    @metadata = MongoReflector.reflect(params[:collection])
    @klass = @metadata.reference
  	selector = @klass.singleton_methods(false).include?(:get) ? :get : :find
    @model = @klass.send(selector, params[:id])
	end
end
