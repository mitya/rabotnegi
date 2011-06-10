class Admin::LogItemsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def index
		@log_items = MongoLog::Item.order_by([[:_id, :desc]]).paginate(per_page: 100, page: params[:page])
	  render layout: !request.xhr?
	end

	def show
  	@log_item = MongoLog::Item.find(params[:id])
	end
end
