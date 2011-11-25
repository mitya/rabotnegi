class  Admin::DataController < ApplicationController
  before_filter :admin_required
  before_filter :load_metadata
  layout 'admin'

  def index
    @scope = @klass.reference.respond_to?(:query) ? @klass.reference.query(q: params[:q]) : @klass.reference
    @models = @scope.order_by(@klass.list_order).paginate(params[:page], @klass.list_page_size)
  end  
  
	def show
    @model = @klass.reference.get(params[:id])
	end
	
  def edit
    @model = @klass.reference.get(params[:id])
  end 
  
  # def update
  #   @model = @klass.reference.get(params[:id])
  #   update_model @model, params[:vacancy], url(:admin, @model)
  # end
	
private
  
  def load_metadata
    @klass = MongoReflector.reflect(params[:collection])    
  end	
end
