# coding: utf-8

class Admin::EmployersController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  model Employer

	def index
		@models = Model.paginate(params[:page], 30)
	end
	
	def show
  	find_model
	end
	
	def edit
		find_model
	end
	
	def update
		find_model
		update_model @model, params[:employer], url(:admin, @model)
	end
end
