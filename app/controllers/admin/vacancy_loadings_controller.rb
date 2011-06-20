# coding: utf-8

class Admin::VacancyLoadingsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  Model = RabotaRu::VacancyLoading

	def index
		@models = Model.reverse.paginate(params[:page], 30)
	  render layout: !request.xhr?
	end
	
	def show
  	@model = Model.find(params[:id])
	end
end
