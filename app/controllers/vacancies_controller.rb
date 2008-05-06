class VacanciesController < ApplicationController
	@@default_sort_field = :salary_min
	@@default_sort_direction = :asc
	
	before_filter :set_employer_authentified
	before_filter :redirect_if_unauthetified,    :only => [:list_my, :edit, :update, :delete]
	before_filter :redirect_if_unauthorized,     :only => [:edit, :update, :delete]

	
	def my
		load_employer
		@vacancies = @employer.vacancies.find :all,
			:order => 'title',
			:select => 'id, title, external_id, salary_min, salary_max, employer_name'
	end

	def show
		@vacancy = Vacancy.find params[:id]
		render_multiview :show
	end

	def new
		@vacancy = Vacancy.new
		@vacancy.city = :msk
    render_multiview :form, :url => "/vacancies", :method => :post, :action_label => 'Опубликовать'
	end

	def edit
		@vacancy = Vacancy.find params[:id] 
		render_multiview :form, :url => "/vacancies/#{@vacancy.id}", :method => :put, :action_label => 'Сохранить'
	end
	
	def index
		if params[:city]
			params[:q_esc] = "%#{params[:q]}%" if params[:q]
			filter_template = 'city=:city'
			filter_template << ' and industry=:industry' if params[:industry] != 'any'
			filter_template << ' and (title like :q_esc or employer_name like :q_esc)' if params[:q_esc]
			
			vacancies_count = Vacancy.count(:all, :conditions => [filter_template, params])
			@pager = Paginator.new(self, vacancies_count, 50, params[:p])
			@vacancies = Vacancy.find :all,
					:conditions => [filter_template, params],
					:order => sort_expression,
					:limit => @pager.items_per_page,
					:offset => @pager.current.offset,
					:select => 'id, title, external_id, salary_min, salary_max, employer_name'
					
			render :action => (@vacancies.empty? ? 'list_empty' : 'list')
		else
		  params[:city] = :msk
			params[:industry] = :any
			@page_id = 'vacancies-search-page'
      render_multiview :search_form
		end
	end

	def create
		@vacancy = Vacancy.new(params[:vacancy])
		if @employer_authenticated
			load_employer
			@vacancy.employer_id = @employer.id
			@vacancy.employer_name = @employer.name 
		end

		if @vacancy.save
			flash[:notice] = 'Вакансия опубликована'
			redirect
		else	
			render :action => 'new' 
		end
	end

	def update
		@vacancy = Vacancy.find(params[:id])
		if @vacancy.update_attributes(params[:vacancy])
			flash[:notice] = 'Вакансия сохранена'
			redirect
		else
			render :action => 'edit' 
		end
	end

	def delete
		@vacancy = Vacancy.find(params[:id])
		@vacancy.destroy
		flash[:notice] = "Вакансия «#{@vacancy.title}» удалена"
		redirect 
	end

	def description
		@vacancy = Vacancy.find params[:id]
		render :partial => 'description'
	end	


private
	def redirect
		if @employer_authenticated
			redirect_to my_vacancies_url
		else
			redirect_to employers_url 
		end
	end

	def sort_expression
		if !@sort_field && !@sort_direction
			if !params[:s]
				@sort_field = @@default_sort_field
				@sort_direction = @@default_sort_direction
			else
				sort_expr = params[:s]
				if sort_expr.first == '-'
					@sort_direction = :desc
					@sort_field = sort_expr[1...sort_expr.length]
				else
					@sort_direction = :asc
					@sort_field = sort_expr 
				end
			end
				@sort_field = @sort_field.to_sym
		end
		"#{@sort_field} #{@sort_direction}"
	end

	def set_employer_authentified
		@employer_authenticated = session[:employer_id] ? true : false
		true 
	end

	def load_employer
		@employer ||= Employer.find session[:employer_id]
	end

	def redirect_if_unauthetified
		redirect if !@employer_authenticated
	end

	def redirect_if_unauthorized
		load_employer
		redirect if !@employer.find_in_vacancies(params[:id])
	end
end