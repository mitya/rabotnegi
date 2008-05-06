ActionController::Routing::Routes.draw do |map|
  GET = { :method => :get } unless defined? GET
  POST = { :method => :post } unless defined? POST
  PUT = { :method => :put } unless defined? PUT
  DELETE = { :method => :delete } unless defined? DELETE

  map.nice_vacancies '/vacancies/:city/:industry', :controller => 'vacancies', :action => 'index',
      :defaults => {:city => nil, :industry => 'any'}, :requirements => {:city => /(?!(new|\d+))\w*/}, :conditions => GET

	map.resources :vacancies, 
	  :member => { :description => :get	},
	  :collection => { :my => :get }

	map.resources :resumes, :collection => {
		:login => :get,
		:log_in => :post,
		:log_out => :get
	}

	map.resources :employers, :collection => {
		:log_in => :post,
		:log_out => :get
  }
	
  map.root :controller => 'vacancies', :action => 'index'
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.connect '/:controller/:action'
end