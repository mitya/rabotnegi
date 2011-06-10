# coding: utf-8

class Admin::VacanciesController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def index
		@vacancies = Vacancy.where.paginate(per_page: 30, page: params[:page])
	  render layout: !request.xhr?
	end
	
	def show
  	@vacancy = Vacancy.get(params[:id])
	end
	
	def edit
		@vacancy = Vacancy.get(params[:id])
	end
	
	def update
		@vacancy = Vacancy.get(params[:id])
		@vacancy.attributes = params[:vacancy]
		if @vacancy.save
		  redirect_to url(:admin, @vacancy), notice: "Изменения сохранены"
	  else
	    render :edit
    end
	end
end
