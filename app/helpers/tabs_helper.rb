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