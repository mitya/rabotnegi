class Admin::VacanciesController < ApplicationController
  before_filter :admin_required
  layout 'admin'

	def index
		@vacancies = Vacancy.paginate :per_page => 30, :page => params[:page]
		respond_to do |format|
			format.html unless request.xhr?
			format.html { render partial: 'list' } if request.xhr?
		end
	end
	
	def edit
		@vacancy = Vacancy.find(params[:id])
		render partial: 'edit', object: @vacancy
	end
	
	def update
		@vacancy = Vacancy.find(params[:id])
		@vacancy.attributes = params[:vacancy]
		@vacancy.save!
		render partial: 'show', object: @vacancy
	end
end
