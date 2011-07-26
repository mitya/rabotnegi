class Admin::LogItemsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def index
		@log_items = MongoLog::Item.search(params[:q]).order_by([[:_id, :desc]]).paginate(params[:page], 100)
	  render layout: !request.xhr?
	end

	def show
  	@log_item = MongoLog::Item.find(params[:id])
	end
end
