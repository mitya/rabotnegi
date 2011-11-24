class  Admin::DataController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  # collection, ...
  def index
    @metadata = MongoReflector.reflect(params[:collection])
    @klass = @metadata.klass
    @scope = @klass.respond_to?(:query) ? @klass.query(q: params[:q]) : @klass
    @models = @scope.paginate(params[:page], 30)
    render :index
  end  
end
