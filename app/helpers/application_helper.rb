module CollectionsHelper
	def found_objects_info(collection, word, e1, e2, e5)
		if collection.total_pages <= 1
			count = collection.size
			object = RussianInflector.inflect(collection.size, word, e1, e2, e5)
		else
			object = RussianInflector.inflect(collection.total_entries, word, e1, e2, e5)
		end
		
		"Найдено <b>#{collection.total_entries}</b> #{object}. 
		 Показаны <b>#{collection.offset + 1}</b> — <b>#{collection.offset + collection.length}</b>"
	end

	def sort_link(collection, label, field)
	  curfld, curdir = collection.sort_field, collection.sort_direction
	  
	  param, sign = if field != curfld then [field, '']
	    elsif curdir == :asc then ["-#{field}", '▲']
      elsif curdir == :desc then ["#{field}", '▼']
    end
	  
		link_to content_tag(:span, sign, :class => 'sort-mark') + label,
			request.request_parameters.merge(:p => nil, :s => param), :class => 'ui'
	end  
end

module CommonHelper
	def add_css_class(element_id, klass)
		content_tag :script, "$('#{element_id}').addClassName('#{klass}')"
	end
	
	def div(id, options = {}, &proc)
		return if options[:only] == false
		return if options[:except] == true
		
		if options[:center]
			concat "<table id='#{id}' class='centered'><tr><td>", proc.binding
			yield
			concat '</table>', proc.binding
    else
  		concat "<div id='#{id}'>", proc.binding
  		yield
  		concat '</div>', proc.binding
		end
	end
	
	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
end

module TabsHelper
	# Returns {tab_id: string, nav_bar_code: symbol, nav_link_id: string}
	def select_nav_element_ids
		contr = self.controller.controller_name.to_sym
		action = self.controller.action_name.to_sym
		
		route = @@routing_table.find{|r| r[0] == contr && r[1] == action}
			
		if !route
			logger.warn("Не найдена строка маршрутизации для #{controller.controller_name}/#{controller.action_name}")
			return { :tab_id => "workers-tab", :nav_bar_code => :workers_nav_bar, :nav_link_id => nil }
		end

		nav_element_ids = {}
		nav_element_ids[:tab_id] = route[2]
		nav_element_ids[:nav_bar_code] = route[3]
		nav_element_ids[:nav_link_id] = route[4]
		
		if contr == :resumes && action == :show
			if params[:id] == 'my'
				nav_element_ids[:tab_id] = 'workers-tab'
				nav_element_ids[:nav_bar_code] = :workers_nav_bar
				nav_element_ids[:nav_link_id] = 'my-resume-link'
			else
				nav_element_ids[:tab_id] = 'employers-tab'
				nav_element_ids[:nav_bar_code] == :employers_nav_bar
				nav_element_ids[:nav_link_id] = 'resume-search-link'
			end
		end
		
		if contr == :vacancies && action == :show
			nav_element_ids[:tab_id] = 'employers-tab'
			nav_element_ids[:nav_bar_code] = :pro_employers_nav_bar
			nav_element_ids[:nav_link_id] = 'my-vacancies-link'
		end

		if nav_element_ids[:nav_bar_code] == :employers_nav_bar
			nav_element_ids[:nav_bar_code] = session[:employer_id] ? :pro_employers_nav_bar : :casual_employers_nav_bar
		end
		
		if nav_element_ids[:nav_link_id] == :vacancies_link
			nav_element_ids[:nav_link_id] = session[:employer_id] ? "my-vacancies-link" : 'vacancies-publication-link'
		end
		
		nav_element_ids
	end
	
	@@routing_table = [
		[:employers, :index,   "employers-tab", :casual_employers_nav_bar, nil],
		[:employers, :new,     "employers-tab", :casual_employers_nav_bar, ''],
		[:employers, :create,  "employers-tab", :casual_employers_nav_bar, ''],
		[:resumes,   :index,   "employers-tab", :employers_nav_bar,      'resume-search-link'],
		[:resumes,   :login,   "workers-tab",   :workers_nav_bar,          'my-resume-link'],
		[:resumes,   :my,      "workers-tab",   :workers_nav_bar,          'my-resume-link'],
		[:resumes,   :show,    "employers-tab", :employers_nav_bar,        'vacancies_link'],
		[:resumes,   :new,     "workers-tab",   :workers_nav_bar,          'my-resume-link'],
		[:resumes,   :edit,    "workers-tab",   :workers_nav_bar,          'my-resume-link'],
		[:vacancies, :show_my, "employers-tab", :pro_employers_nav_bar,    'my-vacancies-link'],
		[:vacancies, :list_my, "employers-tab", :pro_employers_nav_bar,    'my-vacancies-link'],
		[:vacancies, :show,    "employers-tab", :employers_nav_bar,        'vacancies_link'],
		[:vacancies, :new,     "employers-tab", :employers_nav_bar,        'vacancies_link'],
		[:vacancies, :edit,    "employers-tab", :employers_nav_bar,        'vacancies_link'],
		[:vacancies, :index,   "workers-tab",   :workers_nav_bar,        'vacancy-search-link']
	]  
end

module LayoutHelper
  def title(value)
    @page_title = value
  end
  
	def page_title
		@page_title || 'Работнеги.ру'
	end

  def identifier(value)
    @page_id = value
  end
	
	def page_id
	  "id='#{@page_id}'" if @page_id
	end  
end

module ApplicationHelper
  include CollectionsHelper
  include CommonHelper
  include WrappedFormTagHelper
  include FormHelperExtensions
  include TabsHelper
  include LayoutHelper
end