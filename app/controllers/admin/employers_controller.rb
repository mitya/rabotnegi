# coding: utf-8

class Admin::EmployersController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  Model = Employer

	def index
		@models = Model.where.paginate(params[:page], 30)
	  render layout: !request.xhr?
	end
	
	def show
  	@model = Model.get(params[:id])
	end
	
	def edit
		@model = Model.get(params[:id])
	end
	
	def update
		@model = Model.get(params[:id])
		@model.attributes = params[:employer]
		if @model.save
		  redirect_to url(:admin, @model), notice: "Изменения сохранены"
	  else
	    render :edit
    end
	end
end
