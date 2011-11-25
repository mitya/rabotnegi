# coding: utf-8

class Admin::VacanciesController < ApplicationController
  before_filter :admin_required
  layout 'admin'

  model Vacancy

	def index
		@vacancies = Model.search(q: params[:q]).paginate(params[:page], 30)
	end
	
	def show
  	find_model
	end

	def edit
		find_model
	end
	
	def update
		find_model
		update_model @model, params[:vacancy], url(:admin, @model)
	end
end
