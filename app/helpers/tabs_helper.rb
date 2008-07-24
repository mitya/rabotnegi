SiteLocation = Struct.new(:tab, :navigation_bar, :navigation_link)

module TabsHelper
	def determine_location
		location = @@routes[[controller.controller_name.to_sym, controller.action_name.to_sym]] || raise("Route Not Found")
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
		[:vacancies, :my      ] => SiteLocation.new("employers-tab", :pro_employers,    'my-vacancies-link'),
		[:vacancies, :show    ] => SiteLocation.new("employers-tab", :employers,        'vacancies-link'),
		[:vacancies, :new     ] => SiteLocation.new("employers-tab", :employers,        'vacancies-link'),
		[:vacancies, :edit    ] => SiteLocation.new("employers-tab", :employers,        'vacancies-link'),
		[:vacancies, :index   ] => SiteLocation.new("workers-tab",   :workers,          'vacancy-search-link')
	}	
end