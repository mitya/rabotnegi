class  Admin::DataController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  # collection, ...
  def index
    @metadata = MongoReflector.reflect(params[:collection])
    @models = @metadata.klass.search(q: params[:q]).paginate(params[:page], 30)
  end
  
end
