class AdminItemsController < ApplicationController
  before_filter :admin_required
  before_filter :load_metadata
  layout 'admin'

  def index
    @scope = @collection.klass.respond_to?(:query) ? @collection.klass.query(q: params[:q]) : @collection.klass
    @models = @scope.order_by(@collection.list_order).paginate(params[:page], @collection.list_page_size)
  end  
  
	def show
    @model = @collection.klass.get(params[:id])
	end
	
  def edit
    @model = @collection.klass.get(params[:id])
  end 
  
  def update
    @model = @collection.klass.get(params[:id])
    update_model @model, params[@collection.singular], url(:admin_data_item, @collection.key, @model)
  end
	
  private
  
  def load_metadata
    @collection = MongoReflector.metadata_for(params[:collection])
  end	
end
