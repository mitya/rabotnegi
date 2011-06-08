class Admin::LogItemsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def index
		@log_items = MongoLog::Item.order_by([[:_id, :desc]]).paginate(per_page: 100, page: params[:page])
		respond_to do |format|
			format.html unless request.xhr?
			format.html { render partial: 'list' } if request.xhr?
		end
	end
end
