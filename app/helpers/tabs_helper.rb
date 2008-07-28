SiteLocation = Struct.new(:tab, :navigation_bar, :navigation_link)

module TabsHelper
	def determine_location
		location = @@routes[[params[:controller].to_sym, params[:action].to_sym]] || raise("Route Not Found")
		location.navigation_bar = session[:employer_id] ? :pro_employers : :casual_employers if location.navigation_bar == :employers
		location
	rescue
		logger.warn("Не найдена строка маршрутизации для #{controller.controller_name}/#{controller.action_name}")
		SiteLocation.new("workers-tab", :workers, nil)
	end
	
	@@routes = {
		[:employers, :index   ] => SiteLocation.new("employers-tab", :casual_employers, nil),
		[:employers, :new     ] => SiteLocation.new("employers-tab", :casual_employers, nil),
		[:employers, :create  ] => SiteLocation.new("employers-tab", :casual_employers, nil),
		[:resumes,   :index   ] => SiteLocation.new("employers-tab", :employers,        'resume-search-link'),
		[:resumes,   :show    ] => SiteLocation.new("employers-tab", :employers,        'resume-search-link'),
		[:resumes,   :login   ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:resumes,   :my      ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:resumes,   :new     ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:resumes,   :edit    ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:resumes,   :update  ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:resumes,   :create  ] => SiteLocation.new("workers-tab",   :workers,          'my-resume-link'),
		[:vacancies, :index   ] => SiteLocation.new("workers-tab",   :workers,          'vacancy-search-link'),
		[:'employers/casual/vacancies', :new] => SiteLocation.new("employers-tab", :casual_employers, 'vacancies-link'),
		[:'employers/casual/vacancies', :create] => SiteLocation.new("employers-tab", :casual_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :index] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :show] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :edit] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :new] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :update] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link'),
		[:'employers/pro/vacancies', :create] => SiteLocation.new("employers-tab", :pro_employers, 'vacancies-link')
	}	
end