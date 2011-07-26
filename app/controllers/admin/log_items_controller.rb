class Admin::LogItemsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  model MongoLog::Item

	def index
		@models = Model.search(params[:q]).order_by([[:_id, :desc]]).paginate(params[:page], 100)
	end

	def show
	  find_model
	end
end
