# coding: utf-8

class Admin::VacancyLoadingsController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  model RabotaRu::VacancyLoading

	def index
		@models = Model.reverse.paginate(params[:page], 30)
	end
	
	def show
	  find_model
	end
end
