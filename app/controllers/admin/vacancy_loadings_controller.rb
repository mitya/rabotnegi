# coding: utf-8

class Admin::VacancyLoadingsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  Model = RabotaRu::VacancyLoading

	def index
		@models = Model.reverse.paginate(per_page: 30, page: params[:page])
	  render layout: !request.xhr?
	end
	
	def show
  	@model = Model.find(params[:id])
	end
end
